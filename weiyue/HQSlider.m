//
//  HQSlider.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQSlider.h"

@interface HQSlider ()

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *slidedLineColor;
@property (nonatomic, strong) UIColor *circleColor;

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat circleRadius;
@property (nonatomic, assign) BOOL    isSliding;

@end

@implementation HQSlider

- (id)initWithFrame:(CGRect)frame direction:(HQSliderDirection)direction withid:(int)ID{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

            _minValue = 0;
            _maxValue = 1;
 
        
        _direction = direction;
        _lineColor = [UIColor whiteColor];
        _slidedLineColor = [UIColor redColor];
        _circleColor = [UIColor whiteColor];
        
        _ratioNum = 0.0;
        _lineWidth = 1;
        _circleRadius = 10;
        
        
    }
    return self;
    
}



- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    
    CGFloat startLineX = (_direction == HQSliderDirectionHorizonal ? _circleRadius : (self.frame.size.width - _lineWidth) / 2);
    CGFloat startLineY = (_direction == HQSliderDirectionHorizonal ? (self.frame.size.height - _lineWidth) / 2 : _circleRadius);
    
    CGFloat endLineX = (_direction == HQSliderDirectionHorizonal ? self.frame.size.width - _circleRadius : (self.frame.size.width - _lineWidth) / 2);
    CGFloat endLineY = (_direction == HQSliderDirectionHorizonal ? (self.frame.size.height - _lineWidth) / 2 : self.frame.size.height- _circleRadius);
    
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, endLineX, endLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    
    CGContextSetStrokeColorWithColor(context, _slidedLineColor.CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    
    CGFloat slidedLineX = (_direction == HQSliderDirectionHorizonal ? MAX(_circleRadius, (_ratioNum * self.frame.size.width - _circleRadius)) : startLineX);
    
    CGFloat slidedLineY = (_direction == HQSliderDirectionHorizonal ? startLineY : MAX(_circleRadius, (_ratioNum * self.frame.size.height - _circleRadius)));
    
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, slidedLineX, slidedLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    CGFloat penWidth = 1.f;
    CGContextSetStrokeColorWithColor(context, _circleColor.CGColor);
    CGContextSetLineWidth(context, penWidth);
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGContextSetShadow(context, CGSizeMake(1, 1), 1.f);
    
    CGFloat circleX = (_direction == HQSliderDirectionHorizonal ? MAX(_circleRadius + penWidth, slidedLineX - penWidth ) : startLineX);
    CGFloat circleY = (_direction == HQSliderDirectionHorizonal ? startLineY : MAX(_circleRadius + penWidth, slidedLineY - penWidth));
    CGContextAddArc(context, circleX, circleY, _circleRadius, 0, 2 * M_PI, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    CGContextSetStrokeColorWithColor(context, nil);
    CGContextSetLineWidth(context, 0);
    CGContextSetFillColorWithColor(context, _circleColor.CGColor);
    CGContextAddArc(context, circleX, circleY, _circleRadius / 2, 0, 2 * M_PI, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}

#pragma mark 触摸
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}


- (void)updateTouchPoint:(NSSet*)touches {
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    self.ratioNum = (_direction == HQSliderDirectionHorizonal ? touchPoint.x : touchPoint.y) / (_direction == HQSliderDirectionHorizonal ? self.frame.size.width : self.frame.size.height);
}

- (void)setRatioNum:(CGFloat)ratioNum {
    if (_ratioNum != ratioNum) {
        _ratioNum = ratioNum;
        
        self.value = _minValue + ratioNum * (_maxValue - _minValue);
    }
}

- (void)setValue:(CGFloat)value {
    
    if (value != _value) {
        if (value < _minValue) {
            _value = _minValue;
            return;
        } else if (value > _maxValue) {
            _value = _maxValue;
            return;
        }
        _value = value;
        
        [self setNeedsDisplay];
        
        if (_StateChanged) {
            _StateChanged(value);
        }
    }
}


- (void)sliderChangeBlock:(TouchStateChanged)didChangeBlock{
    
    _StateChanged = didChangeBlock;
    
}

- (void)sliderTouchEndBlock:(TouchStateEnd)touchEndBlock{
    
    _StateEnd = touchEndBlock;
    
}


- (void)callbackTouchEnd:(BOOL)isTouchEnd {
    
    _isSliding = !isTouchEnd;
    
    if (isTouchEnd == YES) {
        _StateEnd(_value);
    }
    
    
}
@end
