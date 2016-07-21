//
//  HQ_CommonManager.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQ_CommonManager.h"
#import "HQ_ContantFile.h"
#import "HQ_Mark.h"
#import "HQ_ReaderDataSource.h"
#import "HQDB.h"

@implementation HQ_CommonManager

+ (NSInteger)Manager_getReadTheme{
    
    NSString *themeID = [[NSUserDefaults standardUserDefaults] objectForKey:SAVETHEME];
    
    if (themeID == nil) {
        
        return 1;
        
    }else{
        
        return [themeID integerValue];
        
    }
    
}

+ (NSInteger)Manager_getAutoTime{
    NSString *time = [[NSUserDefaults standardUserDefaults] objectForKey:SAVETIME];
    
    if (time == nil) {
        
        return 0;
        
    }else{
        
        return [time integerValue];
        
    }
}

+(void)saveAutoTime:(NSInteger)time{
    [[NSUserDefaults standardUserDefaults] setValue:@(time) forKey:SAVETIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveCurrentThemeID:(NSInteger)currentThemeID{
    
    [[NSUserDefaults standardUserDefaults] setValue:@(currentThemeID) forKey:SAVETHEME];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
+ (NSUInteger)Manager_getPageBefore{

    HQDB *db = [[HQDB alloc] init];
    NSString *pageID = [db DBCurrentPage:[HQ_ReaderDataSource shareInstance].txtName];
    return [pageID integerValue];
    
}
+ (void)saveCurrentPage:(NSInteger)currentPage{
    
    HQDB *db = [[HQDB alloc] init];
    [db DBsaveCurrentPage:[HQ_ReaderDataSource shareInstance].txtName withCurrentPage:currentPage];
    
}

+ (NSUInteger)Manager_getChapterBefore
{
    HQDB *db = [[HQDB alloc] init];
    NSString *chapterID = [db DBCurrentChapter:[HQ_ReaderDataSource shareInstance].txtName];
    return [chapterID integerValue];
    
}
+ (void)saveCurrentChapter:(NSInteger)currentChapter{
    
    HQDB *db = [[HQDB alloc] init];
    [db DBsaveCurrentChapter:[HQ_ReaderDataSource shareInstance].txtName withCurrentChapter:currentChapter];
    
}


+ (NSUInteger)fontSize
{
    NSUInteger fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:FONT_SIZE];
    if (fontSize == 0) {
        fontSize = 20;
    }
    return fontSize;
}
+ (void)saveFontSize:(NSUInteger)fontSize
{
    [[NSUserDefaults standardUserDefaults] setValue:@(fontSize) forKey:FONT_SIZE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark- 书签保存
+ (void)saveCurrentMark:(NSInteger)currentChapter andChapterRange:(NSRange)chapterRange byChapterContent:(NSString *)chapterContent{
    HQDB *db = [[HQDB alloc] init];
    NSDate *senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    HQ_Mark *eMark = [[HQ_Mark alloc] init];
    eMark.markRange   = NSStringFromRange(chapterRange);
    eMark.markChapter = [NSString stringWithFormat:@"%d",currentChapter];
    eMark.markContent = [chapterContent substringWithRange:chapterRange];
    eMark.markTime    = locationString;
    
    
    if (![self checkIfHasBookmark:chapterRange withChapter:currentChapter]) {
        
        NSData *data = [db DBbookmakr:[HQ_ReaderDataSource shareInstance].txtName];
        NSMutableArray *oldSaveArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (oldSaveArray.count == 0) {
            
            NSMutableArray *newSaveArray = [[NSMutableArray alloc] init];
            [newSaveArray addObject:eMark];

            [db DBsavebookmark:[HQ_ReaderDataSource shareInstance].txtName withdata:[NSKeyedArchiver archivedDataWithRootObject:newSaveArray]];
            
        }else{
            
            [oldSaveArray addObject:eMark];
            [db DBsavebookmark:[HQ_ReaderDataSource shareInstance].txtName withdata:[NSKeyedArchiver archivedDataWithRootObject:oldSaveArray]];
        }
        
    }else{
        
        NSData *data = [db DBbookmakr:[HQ_ReaderDataSource shareInstance].txtName];
        NSMutableArray *oldSaveArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        for (int i = 0 ; i < oldSaveArray.count; i ++) {
            
            HQ_Mark *e = (HQ_Mark *)[oldSaveArray objectAtIndex:i];
            
            if (((NSRangeFromString(e.markRange).location >= chapterRange.location) && (NSRangeFromString(e.markRange).location < chapterRange.location + chapterRange.length)) && ([e.markChapter isEqualToString:[NSString stringWithFormat:@"%d",currentChapter]])) {
                
                [oldSaveArray removeObject:e];


                [db DBsavebookmark:[HQ_ReaderDataSource shareInstance].txtName withdata:[NSKeyedArchiver archivedDataWithRootObject:oldSaveArray]];
                
            }
        }
    }
    
}

+ (BOOL)checkIfHasBookmark:(NSRange)currentRange withChapter:(NSInteger)currentChapter{
    HQDB *db = [[HQDB alloc] init];
    NSData *data = [db DBbookmakr:[HQ_ReaderDataSource shareInstance].txtName];
    NSMutableArray *oldSaveArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    int k = 0;
    for (int i = 0; i < oldSaveArray.count; i ++) {
        HQ_Mark *e = (HQ_Mark *)[oldSaveArray objectAtIndex:i];
        
        if ((NSRangeFromString(e.markRange).location >= currentRange.location) && (NSRangeFromString(e.markRange).location < currentRange.location + currentRange.length) && [e.markChapter isEqualToString:[NSString stringWithFormat:@"%d",currentChapter]]) {
            k++;
        }else{
        }
    }
    if (k >= 1) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSMutableArray *)Manager_getMark{
    HQDB *db = [[HQDB alloc] init];
    NSData *data = [db DBbookmakr:[HQ_ReaderDataSource shareInstance].txtName];
    NSMutableArray *oldSaveArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (oldSaveArray.count == 0) {
        return nil;
    }else{
        return oldSaveArray;
        
    }
}

@end
