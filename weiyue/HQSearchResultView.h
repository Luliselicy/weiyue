//
//  HQSearchResultView.h
//  myReader
//
//  Created by hanqiu on 15/4/9.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQSearchResultView : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableDictionary *pushOrderInfo1;
}
@property (weak,nonatomic)NSMutableDictionary *pushOrderInfo;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@end
