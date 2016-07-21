//
//  HQBookCityView.h
//  myReader
//
//  Created by hanqiu on 15/3/23.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"

@interface HQBookCityView : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    HMSegmentedControl *_segmentedControl;
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *titleview;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
