//
//  HQ_HUDView.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQ_HUDView : UIView
{
    UIFont *msgFont;
}
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, retain) UILabel  *labelText;
@property (nonatomic, assign) float leftMargin;
@property (nonatomic, assign) float topMargin;
@property (nonatomic, assign) float animationLeftScale;
@property (nonatomic, assign) float animationTopScale;
@property (nonatomic, assign) float totalDuration;

+ (void)showMsg:(NSString *)msg inView:(UIView*)theView;

@end
