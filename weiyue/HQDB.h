//
//  HQDB.h
//  weiyue
//
//  Created by hanqiu on 15/5/1.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"

@interface HQDB : NSObject
{
    FMDatabase *_db;
}

-(void)openDB:(NSString *)txtName;

-(void)DBsaveCurrentChapter:(NSString *)txtName withCurrentChapter:(NSInteger)currentChapter;

-(NSString *)DBCurrentChapter:(NSString *)txtName;

-(void)DBsaveCurrentPage:(NSString *)txtName withCurrentPage:(NSInteger)currentPage;

-(NSString *)DBCurrentPage:(NSString *)txtName;

-(void)DBsavebookmark:(NSString *)txtName withdata:(NSData*)data;

-(NSData*)DBbookmakr:(NSString *)txtName;


-(BOOL)deleteTable:(NSString *)tableName;
@end
