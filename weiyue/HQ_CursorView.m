//
//  HQ_CursorView.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQ_CursorView.h"
#define kHQ_CursorWidth 2

@implementation HQ_CursorView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (id)initWithType:(CursorType)type andHeight:(float)cursorHeight byDrawColor:(UIColor *)drawColor{
    self = [super init];
    if (self) {
        _direction = type;
        _cursorHeight = cursorHeight;
        _cursorColor = drawColor;
        self.clipsToBounds = NO;
        
    }
    return self;
    
}


- (void)setSetupPoint:(CGPoint)setupPoint{
    
    self.backgroundColor = _cursorColor;
    
    if (_dragDot) {
        [_dragDot removeFromSuperview];
        _dragDot = nil;
    }
    
    _dragDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"r_drag-dot.png"]];
    
    if (_direction == CursorLeft) {
        self.frame = CGRectMake(setupPoint.x - kHQ_CursorWidth, setupPoint.y - _cursorHeight, kHQ_CursorWidth, _cursorHeight);
        _dragDot.frame = CGRectMake(-7, -8, 15, 17);
        
    }else{
        self.frame = CGRectMake(setupPoint.x, setupPoint.y - _cursorHeight, kHQ_CursorWidth, _cursorHeight);
        _dragDot.frame = CGRectMake(-6, _cursorHeight - 8, 15, 17);
    }
    [self addSubview:_dragDot];
}

- (void)dealloc{
    
    
}
@end
