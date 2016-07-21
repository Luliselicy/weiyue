//
//  HQ_ReaderViewController.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQ_ReaderViewController.h"
#import "HQ_ReaderView.h"
#import "HQ_CommonManager.h"

#define MAX_FONT_SIZE 27
#define MIN_FONT_SIZE 17

@interface HQ_ReaderViewController ()<HQ_ReaderViewDelegate>
{
    HQ_ReaderView *_readerView;
}

@end

@implementation HQ_ReaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _readerView = [[HQ_ReaderView alloc] initWithFrame:CGRectMake(offSet_x, offSet_y, self.view.frame.size.width - 2 * offSet_x, self.view.frame.size.height - offSet_y - 20)];
    _readerView.magnifiterImage = _themeBgImage;
    _readerView.delegate = self;
    [self.view addSubview:_readerView];
    
}

#pragma mark - ReaderViewDelegate
- (void)shutOffGesture:(BOOL)yesOrNo{
    [_delegate shutOffPageViewControllerGesture:yesOrNo];
}

- (void)ciBa:(NSString *)ciBaString{
    
    [_delegate ciBaWithString:ciBaString];
}

- (void)hideSettingToolBar{
    [_delegate hideTheSettingBar];
}

- (void)setFont:(NSUInteger )font_
{
    _readerView.font = font_;
}

- (void)setText:(NSString *)text
{
    _text = text;
    _readerView.text = text;
    
    [_readerView render];
}

- (NSUInteger )font
{
    return _readerView.font;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (CGSize)readerTextSize
{
    return _readerView.bounds.size;
}
@end
