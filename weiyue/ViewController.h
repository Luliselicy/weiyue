//
//  ViewController.h
//  weiyue
//
//  Created by hanqiu on 15/5/1.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout,UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionview;

@property (strong, nonatomic) NSMutableArray *books;
@property (strong, nonatomic) NSArray *fileList;
- (IBAction)editclick:(UIButton *)sender;
@end

