//
//  HQ_DrawerView.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQ_ListView.h"
#import "HQ_Mark.h"

@protocol HQ_DrawerViewDelegate <NSObject>

- (void)openTapGes;
- (void)turnToClickChapter:(NSInteger)chapterIndex;
- (void)turnToClickMark:(HQ_Mark *)eMark;

@end

@interface HQ_DrawerView : UIView<UIGestureRecognizerDelegate,HQ_ListViewDelegate>{
    
    HQ_ListView *_listView;
}
@property(nonatomic, strong) UIView *parent;
@property(nonatomic, assign) id<HQ_DrawerViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame parentView:(UIView *)p;

@end
