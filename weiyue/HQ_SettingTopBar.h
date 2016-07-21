//
//  HQ_SettingTopBar.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HQ_SettingTopBarDelegate <NSObject>

- (void)goBack;
- (void)showMultifunctionButton;

@end

@interface HQ_SettingTopBar : UIView

@property(nonatomic,assign)id<HQ_SettingTopBarDelegate>delegate;

- (void)showToolBar;

- (void)hideToolBar;

@end
