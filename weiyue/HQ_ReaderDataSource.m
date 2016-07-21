//
//  HQ_ReaderDataSource.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQ_ReaderDataSource.h"
#import "HQ_CommonManager.h"
#import "HQ_HUDView.h"


@implementation HQ_ReaderDataSource

+ (HQ_ReaderDataSource *)shareInstance{
    
    static HQ_ReaderDataSource *dataSource;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        dataSource = [[HQ_ReaderDataSource alloc] init];
        
        
    });
    
    return dataSource;
}


- (HQ_EveryChapter *)openChapter:(NSInteger)clickChapter{
    
    NSArray *arr = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"txtArr"]];
    _currentChapterIndex = clickChapter;
    
    HQ_EveryChapter *chapter = [[HQ_EveryChapter alloc] init];
    
    chapter.chapterContent = [arr objectAtIndex:_currentChapterIndex-1];
    return chapter;
}

- (HQ_EveryChapter *)openChapter{
    
    NSArray *arr = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"txtArr"]];
    NSUInteger index = [HQ_CommonManager Manager_getChapterBefore];
    
    _currentChapterIndex = index;
    
    HQ_EveryChapter *chapter = [[HQ_EveryChapter alloc] init];
    
    chapter.chapterContent = [arr objectAtIndex:_currentChapterIndex-1];
    
    return chapter;
}

- (NSUInteger)openPage{
    
    NSUInteger index = [HQ_CommonManager Manager_getPageBefore];
    return index;
    
}


- (HQ_EveryChapter *)nextChapter{
    
    if (_currentChapterIndex >= _totalChapter) {
        [HQ_HUDView showMsg:@"没有更多内容了" inView:nil];
        return nil;
        
    }else{
        _currentChapterIndex++;
        
        HQ_EveryChapter *chapter = [HQ_EveryChapter new];
        chapter.chapterContent = readTextData(_currentChapterIndex);
        
        return chapter;
        
    }
    
}

- (HQ_EveryChapter *)preChapter{
    
    if (_currentChapterIndex <= 1) {
        [HQ_HUDView showMsg:@"已经是第一页了" inView:nil];
        return nil;
        
    }else{
        _currentChapterIndex --;
        
        HQ_EveryChapter *chapter = [HQ_EveryChapter new];
        chapter.chapterContent = readTextData(_currentChapterIndex);
        
        return chapter;
    }
}

- (NSInteger)getChapterBeginIndex:(NSInteger)chapter{
    
    NSInteger index = 0;
    for (int i = 1; i < chapter; i ++) {
        
        if (readTextData(i) != nil) {
            
            index += readTextData(i).length;
            
        }else{
            break;
        }
    }
    return index;
}


static NSString *readTextData(NSUInteger index){
    
    NSArray *arr = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"txtArr"]];
    
    
    return [arr objectAtIndex:index-1];
}

@end
