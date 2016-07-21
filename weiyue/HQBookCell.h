//
//  HQBookCell.h
//  myReader
//
//  Created by hanqiu on 15/3/23.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQBookCell : UICollectionViewCell
{
    BOOL isSelect;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UIImageView *grayview;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *btn;
- (IBAction)select:(UIButton *)sender;
@end
