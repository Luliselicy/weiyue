//
//  HQ_CursorView.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef enum {
    CursorLeft = 0,
    CursorRight ,
    
} CursorType;

@interface HQ_CursorView : UIView
{
    UIImageView *_dragDot;
}
@property (nonatomic,assign) CursorType direction;
@property (nonatomic,assign) float cursorHeight;
@property (nonatomic,retain) UIColor *cursorColor;
@property (nonatomic,assign) CGPoint setupPoint;

- (id)initWithType:(CursorType)type andHeight:(float)cursorHeight byDrawColor:(UIColor *)drawColor;

@end
