//
//  HQSearchView.h
//  myReader
//
//  Created by hanqiu on 15/4/8.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQSearchView : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>


- (IBAction)searchclick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;


@end
