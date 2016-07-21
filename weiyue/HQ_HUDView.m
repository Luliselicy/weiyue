//
//  HQ_HUDView.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQ_HUDView.h"

@implementation HQ_HUDView
@synthesize msg;
@synthesize leftMargin;
@synthesize topMargin;
@synthesize animationLeftScale;
@synthesize animationTopScale;
@synthesize totalDuration;
@synthesize labelText;

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

+ (void)showMsg:(NSString *)msg inView:(UIView*)theView{
    
    HQ_HUDView *alert = [[HQ_HUDView alloc] initWithMsg:msg];
    if (!theView){
        [[self getUnhiddenFrontWindowOfApplication] addSubview:alert];
    }
    else{
        [[HQ_HUDView getWindow] addSubview:alert];
    }
    [alert showAlert];
    
}

- (void)showAlert{
    
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    self.alpha = 0.0;
    CGPoint center=[HQ_HUDView getWindow].center;
    self.center=center;
    CAKeyframeAnimation* opacityAnimation= [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    opacityAnimation.duration = totalDuration;
    opacityAnimation.cumulative = YES;
    opacityAnimation.repeatCount = 1;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeBoth;
    opacityAnimation.values = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.2],
                               [NSNumber numberWithFloat:0.92],
                               [NSNumber numberWithFloat:0.92],
                               [NSNumber numberWithFloat:0.1], nil];
    
    opacityAnimation.keyTimes = [NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat:0.0f],
                                 [NSNumber numberWithFloat:0.08f],
                                 [NSNumber numberWithFloat:0.92f],
                                 [NSNumber numberWithFloat:1.0f], nil];
    
    opacityAnimation.timingFunctions = [NSArray arrayWithObjects:
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];
    
    
    CAKeyframeAnimation* scaleAnimation =[CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = totalDuration;
    scaleAnimation.cumulative = YES;
    scaleAnimation.repeatCount = 1;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:self.animationTopScale],
                             [NSNumber numberWithFloat:1.0f],
                             [NSNumber numberWithFloat:1.0f],
                             [NSNumber numberWithFloat:self.animationTopScale],
                             nil];
    
    scaleAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:0.085f],
                               [NSNumber numberWithFloat:0.92f],
                               [NSNumber numberWithFloat:1.0f], nil];
    
    scaleAnimation.timingFunctions = [NSArray arrayWithObjects:
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];
    
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = totalDuration;
    group.delegate = self;
    group.animations = [NSArray arrayWithObjects:opacityAnimation,scaleAnimation, nil];
    [self.layer addAnimation:group forKey:@"group"];
    
}


- (id)initWithMsg:(NSString*)_msg{
    
    if (self = [super init]) {
        
        self.msg = _msg;
        self.leftMargin = 20;
        
        self.topMargin = 10;
        self.totalDuration = 1.2f;
        
        self.animationTopScale = 1.2;
        self.animationLeftScale = 1.2;
        
        msgFont = [UIFont systemFontOfSize:14.0f];
        CGSize textSize = [self getSizeFromString:msg];
        
        self.bounds = CGRectMake(0, 0, 160, 50);
        self.labelText = [[UILabel alloc] init];
        labelText.text = _msg;
        labelText.numberOfLines = 0;
        labelText.font = msgFont;
        labelText.backgroundColor = [UIColor clearColor];
        labelText.textColor = [UIColor whiteColor];
        labelText.textAlignment = NSTextAlignmentCenter;
        [labelText setFrame:CGRectMake((160 - textSize.width) / 2, 18,textSize.width, textSize.height)];
        [self  addSubview:labelText];
        self.layer.cornerRadius = 10;
        
    }
    return self;
}

+ (UIWindow *) getUnhiddenFrontWindowOfApplication{
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    NSInteger windowCnt = [windows count];
    for (int i = windowCnt - 1; i >= 0; i--) {
        UIWindow* window = [windows objectAtIndex:i];
        if (FALSE == window.hidden) {
            if (window.frame.size.height > 50.0f) {
                return window;
            }
        }
    }
    return NULL;
}

+ (UIWindow*)getWindow{
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    return window;
}

- (CGSize)getSizeFromString:(NSString*)_theString{
    
    UIFont *theFont = msgFont;
    CGSize size = CGSizeMake(160, 2000);
    CGSize tempSize = [_theString sizeWithFont:theFont constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    return tempSize;
}


@end
