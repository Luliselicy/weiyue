//
//  HQ_Paging.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HQ_ContantFile.h"


@interface HQ_Paging : NSObject

@property (nonatomic, copy)               NSString   *contentText;
@property (nonatomic, unsafe_unretained)  NSUInteger  contentFont;
@property (nonatomic, unsafe_unretained)  CGSize     textRenderSize;


- (void)paginate;




- (NSUInteger)pageCount;



- (NSString *)stringOfPage:(NSUInteger)page;


- (NSRange)rangeOfPage:(NSUInteger)page;

@end
