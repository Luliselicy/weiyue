//
//  HQBookCell.m
//  myReader
//
//  Created by hanqiu on 15/3/23.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQBookCell.h"
#import "HQData.h"

@implementation HQBookCell

- (IBAction)select:(UIButton *)sender {
    if (isSelect) {
        [_btn setSelected:NO];
        isSelect =NO;
        [Reader removeDeletelist:_label.text];
    }else
    {
        [_btn setSelected:YES];
        isSelect = YES;
        [Reader addDeletelist:_label.text];
    }
}
@end
