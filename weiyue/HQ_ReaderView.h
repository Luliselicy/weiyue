//
//  HQ_ReaderView.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQ_MagnifiterView.h"
#import "HQ_CursorView.h"



@protocol HQ_ReaderViewDelegate <NSObject>

- (void)shutOffGesture:(BOOL)yesOrNo;
- (void)hideSettingToolBar;
- (void)ciBa:(NSString *)ciBasString;

@end

@interface HQ_ReaderView : UIView

@property(unsafe_unretained, nonatomic)NSUInteger font;
@property(copy, nonatomic)NSString *text;

@property (strong, nonatomic) HQ_CursorView *leftCursor;
@property (strong, nonatomic) HQ_CursorView *rightCursor;
@property (strong, nonatomic) HQ_MagnifiterView *magnifierView;
@property (assign, nonatomic) id<HQ_ReaderViewDelegate>delegate;
@property (strong, nonatomic) UIImage  *magnifiterImage;

- (void)render;

@end

