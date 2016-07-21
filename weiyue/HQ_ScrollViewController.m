//
//  HQ_ScrollViewController.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQ_ScrollViewController.h"
#import "HQ_ReaderViewController.h"
#import "HQ_ReaderDataSource.h"
#import "HQ_EveryChapter.h"
#import "HQ_Paging.h"
#import "HQ_CommonManager.h"
#import "HQ_SettingTopBar.h"
#import "HQ_SettingBottomBar.h"
#import "HQ_ContantFile.h"
#import "HQ_DrawerView.h"
#import "HQ_HUDView.h"
#import "PendulumView.h"
#import "HQ_WebViewControler.h"

@interface HQ_ScrollViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,HQ_SettingTopBarDelegate,HQ_SettingBottomBarDelegate,HQ_DrawerViewDelegate,HQ_ReaderViewControllerDelegate>
{
    UIPageViewController * _pageViewController;
    HQ_Paging             * _paginater;
    BOOL _isTurnOver;
    BOOL _isRight;
    BOOL _pageIsAnimating;
    UITapGestureRecognizer *tapGesRec;
    HQ_SettingTopBar *_settingToolBar;
    HQ_SettingBottomBar *_settingBottomBar;

    UIButton *_markBtn;
    
    CGFloat   _panStartY;
    UIImage  *_themeImage;
    
    PendulumView *pendulum;
    
    NSTimer *timer;
}

@property (copy, nonatomic) NSString* chapterTitle_;
@property (copy, nonatomic) NSString* chapterContent_;
@property (unsafe_unretained, nonatomic) int fontSize;
@property (unsafe_unretained, nonatomic) NSUInteger readOffset;
@property (assign, nonatomic) NSInteger readPage;
@end


@implementation HQ_ScrollViewController


- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger themeID = [HQ_CommonManager Manager_getReadTheme];
    if (themeID == 1) {
        _themeImage = [UIImage imageNamed:@"reader_bg1.png"];
    }else{
        _themeImage = [UIImage imageNamed:[NSString stringWithFormat:@"reader_bg%ld.png",(long)themeID]];
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:_themeImage];
    UIColor *ballColor = [UIColor colorWithRed:0.47 green:0.60 blue:0.89 alpha:1];
    pendulum = [[PendulumView alloc] initWithFrame:self.view.bounds ballColor:ballColor];
    [pendulum startAnimating];
    [self.view addSubview:pendulum];

    [self getbook];
    
    
    
    self.fontSize = [HQ_CommonManager fontSize];
    _pageIsAnimating = NO;
    
    tapGesRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callToolBar)];
    [self.view addGestureRecognizer:tapGesRec];
    
    UIPanGestureRecognizer *panGesRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(LightRegulation:)];
    panGesRec.maximumNumberOfTouches = 2;
    panGesRec.minimumNumberOfTouches = 2;
    [self.view addGestureRecognizer:panGesRec];
    
    float time = [HQ_CommonManager Manager_getAutoTime];
    if (time == 0) {
        [timer invalidate];
        timer =nil;
    }else{
        timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(autoplay) userInfo:nil repeats:YES];
    }
    
}

- (void)autoplay{
    _isTurnOver = NO;
    _isRight = YES;
    
    
    HQ_ReaderViewController *reader = _pageViewController.viewControllers.lastObject;
    NSUInteger currentPage = [_pageViewController.viewControllers.lastObject currentPage];;
    
    
    if (_pageIsAnimating && currentPage <= 0) {
        HQ_EveryChapter *chapter = [[HQ_ReaderDataSource shareInstance] nextChapter];
        [self parseChapter:chapter];
        
    }
    
    
    if (currentPage >= self.lastPage) {
        
        _isTurnOver = YES;
        HQ_EveryChapter *chapter = [[HQ_ReaderDataSource shareInstance] nextChapter];
        if (chapter == nil || chapter.chapterContent == nil || [chapter.chapterContent isEqualToString:@""]) {
            _pageIsAnimating = NO;
            [timer invalidate];
            timer = nil;
        }
        [self parseChapter:chapter];
        currentPage = -1;
    }
    
    _pageIsAnimating = YES;
    
    HQ_ReaderViewController *textController = [self readerControllerWithPage:currentPage + 1];

    NSArray *arr = [NSArray arrayWithObjects:textController, nil];
    [_pageViewController setViewControllers:arr direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    reader.currentPage++;
}

-(void)getbook
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"novels"]];
        NSString* txt = [[NSUserDefaults standardUserDefaults] valueForKey:@"txt"];
        NSString* doc =@".";
        NSRange range1 = [txt rangeOfString:doc];
        NSInteger location = range1.location;
        NSString *txtName= [txt substringToIndex:location];
        
        NSString* path = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@.txt",txtName]];
        NSString *text = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *txtArr = [NSArray arrayWithArray:[text componentsSeparatedByString:@"汉秋"]];
        [[NSUserDefaults standardUserDefaults] setObject:txtArr forKey:@"txtArr"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [HQ_ReaderDataSource shareInstance].totalChapter = [txtArr count];
            [HQ_ReaderDataSource shareInstance].txtName = txtName;
            
            HQ_EveryChapter *chapter = [[HQ_ReaderDataSource shareInstance] openChapter];
            [self parseChapter:chapter];
            [self initPageView:NO];
            [pendulum stopAnimating];
            [pendulum removeFromSuperview];
            
        });
        
    });
    
}


- (void)LightRegulation:(UIPanGestureRecognizer *)recognizer{
    CGPoint touchPoint = [recognizer locationInView:self.view];
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan:
        {
            
            _panStartY = touchPoint.y;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            
            CGFloat offSetY = touchPoint.y - _panStartY;
            CGFloat light = [UIScreen mainScreen].brightness;
            if (offSetY >=0 ) {
                
                CGFloat percent = offSetY/self.view.frame.size.height;
                CGFloat regulaLight = percent + light;
                if (regulaLight >= 1.0) {
                    regulaLight = 1.0;
                }
                [[UIScreen mainScreen] setBrightness:regulaLight];
            }else{
                CGFloat percent = offSetY/self.view.frame.size.height;
                CGFloat regulaLight = light + percent;
                if (regulaLight <= 0.0) {
                    regulaLight = 0.0;
                }
                [[UIScreen mainScreen] setBrightness:regulaLight];
                
                
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:{
            
        }
            break;
        default:
            break;
    }
}

- (void)callToolBar{
    
    if (_settingToolBar == nil) {
        [timer invalidate];
        timer = nil;
        _settingToolBar= [[HQ_SettingTopBar alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, 64)];
        [self.view addSubview:_settingToolBar];
        _settingToolBar.delegate = self;
        [_settingToolBar showToolBar];
        [self shutOffPageViewControllerGesture:YES];
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        float time = [HQ_CommonManager Manager_getAutoTime];
        if (time == 0) {

        }else{
            timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(autoplay) userInfo:nil repeats:YES];
        }
        [self hideMultifunctionButton];
        [_settingToolBar hideToolBar];
        _settingToolBar = nil;
        [self shutOffPageViewControllerGesture:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }
    
    if (_settingBottomBar == nil) {
        _settingBottomBar = [[HQ_SettingBottomBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, kBottomBarH)];
        [self.view addSubview:_settingBottomBar];
        _settingBottomBar.chapterTotalPage = _paginater.pageCount;
        _settingBottomBar.chapterCurrentPage = _readPage;
        _settingBottomBar.currentChapter = [HQ_ReaderDataSource shareInstance].currentChapterIndex;
        _settingBottomBar.delegate = self;
        [_settingBottomBar showToolBar];
        [self shutOffPageViewControllerGesture:YES];
        
    }else{
        
        [_settingBottomBar hideToolBar];
        _settingBottomBar = nil;
        [self shutOffPageViewControllerGesture:NO];
        
    }
    
}

- (void)initPageView:(BOOL)isFromMenu;
{
    if (_pageViewController) {
        [_pageViewController removeFromParentViewController];
        _pageViewController = nil;
    }
    _pageViewController = [[UIPageViewController alloc] init];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    if (isFromMenu == YES) {
        [self showPage:0];
    }else{
        NSUInteger beforePage = [[HQ_ReaderDataSource shareInstance] openPage];
        [self showPage:beforePage];
    }
    
    
    
    
}

#pragma mark - readerVcDelegate
- (void)shutOffPageViewControllerGesture:(BOOL)yesOrNo{
    
    if (yesOrNo == NO) {
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
    }else{
        _pageViewController.delegate = nil;
        _pageViewController.dataSource = nil;
        
    }
}

- (void)ciBaWithString:(NSString *)ciBaString{
    
    HQ_WebViewControler *webView = [[HQ_WebViewControler alloc] initWithSelectString:ciBaString];
    [self presentViewController:webView animated:YES completion:NULL];
    
}


#pragma mark - 点击侧边栏目录跳转
- (void)turnToClickChapter:(NSInteger)chapterIndex{
    
    HQ_EveryChapter *chapter = [[HQ_ReaderDataSource shareInstance] openChapter:chapterIndex + 1];
    [self parseChapter:chapter];
    [self initPageView:YES];
    
}

- (void)sliderToChapterPage:(NSInteger)chapterIndex{
    [self showPage:chapterIndex - 1];
}

#pragma mark - 点击侧边栏书签跳转
- (void)turnToClickMark:(HQ_Mark *)eMark{
    
    HQ_EveryChapter *e_chapter = [[HQ_ReaderDataSource shareInstance] openChapter:[eMark.markChapter integerValue]];
    [self parseChapter:e_chapter];
    
    if (_pageViewController) {
        
        [_pageViewController.view removeFromSuperview];
        [_pageViewController removeFromParentViewController];
        _pageViewController = nil;
    }
    _pageViewController = [[UIPageViewController alloc] init];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    int showPage = [self findOffsetInNewPage:NSRangeFromString(eMark.markRange).location];
    [self showPage:showPage];
}

#pragma mark - 上一章
- (void)turnToPreChapter{
    
    if ([HQ_ReaderDataSource shareInstance].currentChapterIndex <= 1) {
        [HQ_HUDView showMsg:@"已经是第一章" inView:self.view];
        return;
    }
    [self turnToClickChapter:[HQ_ReaderDataSource shareInstance].currentChapterIndex - 2];
    
}
#pragma mark - 下一章
- (void)turnToNextChapter{
    
    if ([HQ_ReaderDataSource shareInstance].currentChapterIndex == [HQ_ReaderDataSource shareInstance].totalChapter) {
        [HQ_HUDView showMsg:@"已经是最后一章" inView:self.view];
        return;
    }
    [self turnToClickChapter:[HQ_ReaderDataSource shareInstance].currentChapterIndex];
    
}

#pragma mark - 隐藏设置bar
- (void)hideTheSettingBar{
    
    if (_settingToolBar == nil) {
        
    }else{
        [self hideMultifunctionButton];
        [_settingToolBar hideToolBar];
        _settingToolBar = nil;
        [self shutOffPageViewControllerGesture:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }
    
    if (_settingBottomBar == nil) {
        
    }else{
        
        [_settingBottomBar hideToolBar];
        _settingBottomBar = nil;
        [self shutOffPageViewControllerGesture:NO];
    }
}


#pragma mark --
- (void)parseChapter:(HQ_EveryChapter *)chapter
{
    self.chapterContent_ = chapter.chapterContent;
    self.chapterTitle_ = chapter.chapterTitle;
    [self configPaginater];
}


- (void)configPaginater
{
    _paginater = [[HQ_Paging alloc] init];
    HQ_ReaderViewController *temp = [[HQ_ReaderViewController alloc] init];
    temp.delegate = self;
    [temp view];
    _paginater.contentFont = self.fontSize;
    _paginater.textRenderSize = [temp readerTextSize];
    _paginater.contentText = self.chapterContent_;
    [_paginater paginate];
}

- (void)readPositionRecord
{
    int currentPage = [_pageViewController.viewControllers.lastObject currentPage];
    NSRange range = [_paginater rangeOfPage:currentPage];
    self.readOffset = range.location;
}

- (void)fontSizeChanged:(int)fontSize
{
    [self readPositionRecord];
    self.fontSize = fontSize;
    _paginater.contentFont = self.fontSize;
    [_paginater paginate];
    int showPage = [self findOffsetInNewPage:self.readOffset];
    [self showPage:showPage];
    
}

#pragma mark - 直接隐藏多功能下拉按钮
- (void)hideMultifunctionButton{
    if (_markBtn) {

        [_markBtn removeFromSuperview];
        _markBtn = nil;
        
    }
}

#pragma mark - TopbarDelegate
- (void)goBack{
    
    [HQ_CommonManager saveCurrentPage:_readPage];
    [HQ_CommonManager saveCurrentChapter:[HQ_ReaderDataSource shareInstance].currentChapterIndex];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - 动画显示或隐藏多功能下拉按钮
- (void)showMultifunctionButton{
    
    if (_markBtn) {
       
            DELAYEXECUTE(0.12, {[_markBtn removeFromSuperview];
                _markBtn = nil;
                
                             });
        return;
    }
    

    
    
    _markBtn = [UIButton buttonWithType:0];
    [_markBtn setTitle:@"书签" forState:0];
    _markBtn.backgroundColor = [UIColor colorWithRed:59/255.0 green:59/255.0 blue:59/255.0 alpha:1.0];
    _markBtn.frame = CGRectMake(self.view.frame.size.width - 70 , 20 + 44 + 16 , 44, 44);
    _markBtn.layer.cornerRadius = 22;
    
    NSRange range = [_paginater rangeOfPage:_readPage];
    if ([HQ_CommonManager checkIfHasBookmark:range withChapter:[HQ_ReaderDataSource shareInstance].currentChapterIndex]) {
        _markBtn.selected = YES;
    }else{
        _markBtn.selected = NO;
    }
    
    if (_markBtn.selected == YES) {
        
        [_markBtn setTitleColor:[UIColor redColor] forState:0];
        
    }else{
        
        [_markBtn setTitleColor:[UIColor whiteColor] forState:0];
    }
    _markBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_markBtn addTarget:self action:@selector(doMark) forControlEvents:UIControlEventTouchUpInside];
    
    DELAYEXECUTE(0.12, {[self.view addSubview:_markBtn];});
    
}




- (void)doMark{
    
    _markBtn.selected = !_markBtn.selected;
    if (_markBtn.selected == YES) {
        [_markBtn setTitleColor:[UIColor redColor] forState:0];
    }else{
        [_markBtn setTitleColor:[UIColor whiteColor] forState:0];
    }
    
    NSRange range = [_paginater rangeOfPage:_readPage];
    [HQ_CommonManager saveCurrentMark:[HQ_ReaderDataSource shareInstance].currentChapterIndex andChapterRange:range byChapterContent:_paginater.contentText];
    
    [_settingBottomBar hideToolBar];
    _settingBottomBar = nil;
    
    [_settingToolBar hideToolBar];
    _settingToolBar = nil;
    [self shutOffPageViewControllerGesture:NO];
    [self hideMultifunctionButton];
}



#pragma mark - 底部左侧按钮触发事件
- (void)callDrawerView{
    
    [self callToolBar];
    tapGesRec.enabled = NO;

    DELAYEXECUTE(0.18, {HQ_DrawerView *drawerView = [[HQ_DrawerView alloc] initWithFrame:self.view.frame parentView:self.view];drawerView.delegate = self;
        [self.view addSubview:drawerView];});
    
    
}





- (void)openTapGes{
    
    tapGesRec.enabled = YES;
}


#pragma mark - 改变主题
- (void)themeButtonAction:(id)myself themeIndex:(NSInteger)theme{
    
    if (theme == 1) {
        _themeImage = nil;
    }else{
        _themeImage = [UIImage imageNamed:[NSString stringWithFormat:@"reader_bg%ld.png",(long)theme]];
    }
    
    [self showPage:self.readPage];
}

#pragma mark - 根据偏移值找到新的页码
- (NSUInteger)findOffsetInNewPage:(NSUInteger)offset
{
    int pageCount = _paginater.pageCount;
    for (int i = 0; i < pageCount; i++) {
        NSRange range = [_paginater rangeOfPage:i];
        if (range.location <= offset && range.location + range.length > offset) {
            return i;
        }
    }
    return 0;
}

- (void)showPage:(NSUInteger)page
{
    HQ_ReaderViewController *readerController = [self readerControllerWithPage:page];
    [_pageViewController setViewControllers:@[readerController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:^(BOOL f){
                                     
                                 }];
}


- (HQ_ReaderViewController *)readerControllerWithPage:(NSUInteger)page
{
    _readPage = page;
    HQ_ReaderViewController *textController = [[HQ_ReaderViewController alloc] init];
    textController.delegate = self;
    textController.themeBgImage = _themeImage;
    if (_themeImage == nil) {
        textController.view.backgroundColor = [UIColor whiteColor];
    }else{
        textController.view.backgroundColor = [UIColor colorWithPatternImage:_themeImage];
    }
    
    [textController view];
    textController.currentPage = page;
    textController.totalPage = _paginater.pageCount;
    textController.chapterTitle = self.chapterTitle_;
    textController.font = self.fontSize;
    textController.text = [_paginater stringOfPage:page];
    
    if (_settingBottomBar) {
        
        float currentPage = [[NSString stringWithFormat:@"%ld",(long)_readPage] floatValue] + 1;
        float totalPage = [[NSString stringWithFormat:@"%ld",(unsigned long)textController.totalPage] floatValue];
        
        float percent;
        if (currentPage == 1) {
            percent = 0;
        }else{
            percent = currentPage/totalPage;
        }
        
        [_settingBottomBar changeSliderRatioNum:percent];
    }
    
    return textController;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UIPageViewDataSource And UIPageViewDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    _isTurnOver = NO;
    _isRight = NO;
    
    HQ_ReaderViewController *reader = (HQ_ReaderViewController *)viewController;
    NSUInteger currentPage = reader.currentPage;
    
    if (_pageIsAnimating && currentPage <= 0) {
        
        HQ_EveryChapter *chapter = [[HQ_ReaderDataSource shareInstance] nextChapter];
        [self parseChapter:chapter];
        
    }
    
    if (currentPage <= 0) {
        
        _isTurnOver = YES;
        HQ_EveryChapter *chapter = [[HQ_ReaderDataSource shareInstance] preChapter];
        if (chapter == nil || chapter.chapterContent == nil || [chapter.chapterContent isEqualToString:@""]) {
            _pageIsAnimating = NO;
            return  nil;
        }
        [self parseChapter:chapter];
        currentPage = self.lastPage + 1;
    }
    
    
    _pageIsAnimating = YES;
    
    HQ_ReaderViewController *textController = [self readerControllerWithPage:currentPage - 1];
    return textController;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    _isTurnOver = NO;
    _isRight = YES;
    
    
    HQ_ReaderViewController *reader = (HQ_ReaderViewController *)viewController;
    NSUInteger currentPage = reader.currentPage;
    
    
    if (_pageIsAnimating && currentPage <= 0) {
        HQ_EveryChapter *chapter = [[HQ_ReaderDataSource shareInstance] nextChapter];
        [self parseChapter:chapter];
        
    }
    
    
    if (currentPage >= self.lastPage) {
        
        _isTurnOver = YES;
        HQ_EveryChapter *chapter = [[HQ_ReaderDataSource shareInstance] nextChapter];
        if (chapter == nil || chapter.chapterContent == nil || [chapter.chapterContent isEqualToString:@""]) {
            _pageIsAnimating = NO;
            return nil;
        }
        [self parseChapter:chapter];
        currentPage = -1;
    }
    
    _pageIsAnimating = YES;
    
    HQ_ReaderViewController *textController = [self readerControllerWithPage:currentPage + 1];
    return textController;
}
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    _pageIsAnimating = NO;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
    if (completed) {
        
        
    }else{
        if (_isTurnOver && !_isRight) {
            
            HQ_EveryChapter *chapter = [[HQ_ReaderDataSource shareInstance] nextChapter];
            [self parseChapter:chapter];
            
        }else if(_isTurnOver && _isRight){
            
            HQ_EveryChapter *chapter = [[HQ_ReaderDataSource shareInstance] preChapter];
            [self parseChapter:chapter];
            
        }
        
        
    }
}

- (NSUInteger)lastPage
{
    return _paginater.pageCount - 1;
}



@end
