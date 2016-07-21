//
//  HQ_CommonManager.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQ_ContantFile.h"



@interface HQ_CommonManager : NSObject


+ (void)saveCurrentPage:(NSInteger)currentPage;



+ (NSUInteger)Manager_getPageBefore;


+ (void)saveCurrentChapter:(NSInteger)currentChapter;


+ (NSInteger)Manager_getReadTheme;


+ (void)saveCurrentThemeID:(NSInteger)currentThemeID;


+ (NSInteger)Manager_getAutoTime;


+ (void)saveAutoTime:(NSInteger)time;


+ (NSUInteger)Manager_getChapterBefore;


+ (NSUInteger)fontSize;


+ (void)saveFontSize:(NSUInteger)fontSize;


+ (BOOL)checkIfHasBookmark:(NSRange)currentRange withChapter:(NSInteger)currentChapter;


+ (void)saveCurrentMark:(NSInteger)currentChapter andChapterRange:(NSRange)chapterRange byChapterContent:(NSString *)chapterContent;


+ (NSMutableArray *)Manager_getMark;

@end
