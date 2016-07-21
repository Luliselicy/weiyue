//
//  HQSlider.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TouchStateEnd) (CGFloat);
typedef void(^TouchStateChanged) (CGFloat);

typedef enum {
    HQSliderDirectionHorizonal  =   0,
    HQSliderDirectionVertical   =   1
} HQSliderDirection;

@interface HQSlider : UIControl


@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat ratioNum;

@property (nonatomic, assign) HQSliderDirection direction;

@property (nonatomic, copy) TouchStateChanged StateChanged;
@property (nonatomic, copy) TouchStateEnd StateEnd;


- (id)initWithFrame:(CGRect)frame direction:(HQSliderDirection)direction withid:(int)ID;

- (void)sliderChangeBlock:(TouchStateChanged)didChangeBlock;

- (void)sliderTouchEndBlock:(TouchStateEnd)touchEndBlock;


@end
