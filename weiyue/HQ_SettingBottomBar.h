//
//  HQ_SettingBottomBar.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol HQ_SettingBottomBarDelegate <NSObject>

- (void)shutOffPageViewControllerGesture:(BOOL)yesOrNo;
- (void)fontSizeChanged:(int)fontSize;
- (void)callDrawerView;
- (void)turnToNextChapter;
- (void)turnToPreChapter;
- (void)sliderToChapterPage:(NSInteger)chapterIndex;
- (void)themeButtonAction:(id)myself themeIndex:(NSInteger)theme;


@end


@interface HQ_SettingBottomBar : UIView

@property (nonatomic,strong) UIButton *smallFont;
@property (nonatomic,strong) UIButton *bigFont;
@property (nonatomic,assign) id<HQ_SettingBottomBarDelegate>delegate;
@property (nonatomic,assign) NSInteger chapterTotalPage;
@property (nonatomic,assign) NSInteger chapterCurrentPage;
@property (nonatomic,assign) NSInteger currentChapter;

- (void)changeSliderRatioNum:(float)percentNum;

- (void)showToolBar;

- (void)hideToolBar;

@end
