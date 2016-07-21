//
//  HQBookDetailView.h
//  myReader
//
//  Created by hanqiu on 15/3/23.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQBookDetailView : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *txtImage;
@property (weak, nonatomic) IBOutlet UILabel *txtName;
@property (weak, nonatomic) IBOutlet UILabel *txtWriter;
@property (weak, nonatomic) IBOutlet UILabel *txtType;
@property (weak, nonatomic) IBOutlet UIView *clickview;
@property (weak, nonatomic) IBOutlet UIView *showview;
@property (weak, nonatomic) IBOutlet UIButton *btnshow;



@property (strong, nonatomic) NSMutableArray *books;
@property (strong, nonatomic) NSArray *fileList;
@property (weak, nonatomic) IBOutlet UITextView *txtdetail;
- (IBAction)download:(UIButton *)sender;


@end
