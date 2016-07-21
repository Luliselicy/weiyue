//
//  HQ_ReaderViewController.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//



#import <UIKit/UIKit.h>


@protocol HQ_ReaderViewControllerDelegate <NSObject>

- (void)shutOffPageViewControllerGesture:(BOOL)yesOrNo;
- (void)hideTheSettingBar;
- (void)ciBaWithString:(NSString *)ciBaString;

@end


@interface HQ_ReaderViewController : UIViewController

@property (nonatomic,assign) id<HQ_ReaderViewControllerDelegate>delegate;
@property (nonatomic,unsafe_unretained) NSUInteger currentPage;
@property (nonatomic,unsafe_unretained) NSUInteger totalPage;
@property (nonatomic,strong)            NSString   *text;
@property (nonatomic,unsafe_unretained) NSUInteger  font;
@property (nonatomic, copy)             NSString   *chapterTitle;
@property (nonatomic, unsafe_unretained,readonly) CGSize readerTextSize;
@property (nonatomic,strong)            UIImage    *themeBgImage;

- (CGSize)readerTextSize;

@end
