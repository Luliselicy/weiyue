//
//  HQ_ReaderDataSource.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQ_EveryChapter.h"

@interface HQ_ReaderDataSource : NSObject

@property (nonatomic,strong)  NSString *txtName;
@property (unsafe_unretained, nonatomic) NSUInteger currentChapterIndex;

@property (unsafe_unretained, nonatomic) NSUInteger totalChapter;

@property (copy             , nonatomic) NSMutableString  *totalString;

@property (strong           , nonatomic) NSMutableArray   *everyChapterRange;

+ (HQ_ReaderDataSource *)shareInstance;



- (HQ_EveryChapter *)openChapter;


- (HQ_EveryChapter *)openChapter:(NSInteger)clickChapter;


- (NSUInteger)openPage;


- (HQ_EveryChapter *)nextChapter;


- (HQ_EveryChapter *)preChapter;


- (NSInteger)getChapterBeginIndex:(NSInteger)chapter;

@end
