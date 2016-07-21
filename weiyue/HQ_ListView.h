//
//  HQ_ListView.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQ_CommonManager.h"
#import "HQ_Mark.h"

@protocol HQ_ListViewDelegate <NSObject>

- (void)clickMark:(HQ_Mark *)eMark;
- (void)clickChapter:(NSInteger)chaperIndex;
- (void)removeHQ_ListView;

@end

@interface HQ_ListView : UIView<UITableViewDataSource,UITableViewDelegate>{
    
    UISegmentedControl *_segmentControl;
    NSInteger dataCount;
    NSMutableArray *_dataSource;
    CGFloat  _panStartX;
    BOOL    _isMenu;
    BOOL    _isMark;
    BOOL    _isNote;
    
}
@property (nonatomic,assign)id<HQ_ListViewDelegate>delegate;

@property (nonatomic,strong)UITableView *listView;

@end
