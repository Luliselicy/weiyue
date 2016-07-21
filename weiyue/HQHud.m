//
//  HQHud.m
//  myReader
//
//  Created by hanqiu on 15/3/30.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQHud.h"

#define kScreen_Height   ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width    ([UIScreen mainScreen].bounds.size.width)
@implementation HQHud

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(id)initWithShowString:(NSString *)showString
{
    self = [super init];
    
    float width = 150;
    float height = 75;
    
    [self setFrame:CGRectMake(kScreen_Width/2-width/2, kScreen_Height/2-height/2, width, height)];
    
    [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    [self.layer setCornerRadius:8];
    
    UILabel* showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    [showLabel setText:showString];
    [showLabel setNumberOfLines:0];
    [showLabel setTextAlignment:NSTextAlignmentCenter];
    [showLabel setFont:[UIFont systemFontOfSize:12]];
    [showLabel setTextColor:[UIColor whiteColor]];
    [showLabel setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:showLabel];
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:(UIView*)self];
    
    return self;
}

-(void)show{
    for (UIView *view in self.superview.subviews)
    {
        if ([view isKindOfClass:[HQHud class]] && view != self) {
            [view removeFromSuperview];
        }
    }
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(hideView) userInfo:nil repeats:NO];
    
}

-(void)hideView{
    
    [UIView animateWithDuration:0.5 animations:
     ^{
         self.alpha = 0;
     } completion:^(BOOL finished)
     {
         [self removeFromSuperview];
     }];
    
}
@end
