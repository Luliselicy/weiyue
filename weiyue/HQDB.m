//
//  HQDB.m
//  weiyue
//
//  Created by hanqiu on 15/5/1.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQDB.h"

@implementation HQDB


-(void)openDB:(NSString *)txtName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",txtName]];
    _db = [FMDatabase databaseWithPath:dbPath];
    
    if (![_db open]) {
        return;
    }
    if (![_db tableExists:@"bookmark"]) {
        [_db executeUpdate:@"create table bookmark (id integer,bookmarkdata blob)"];
    }
    
    if (![_db tableExists:@"currentChapter"]) {
        [_db executeUpdate:@"create table currentChapter (id integer,chapaterindex text)"];
    }
    
    if (![_db tableExists:@"currentPage"]) {
        [_db executeUpdate:@"create table currentPage (id integer,pageindex text)"];
    }

}

-(void)DBsaveCurrentChapter:(NSString *)txtName withCurrentChapter:(NSInteger)currentChapter
{
    [self openDB:txtName];
    FMResultSet *rs = [_db executeQuery:@"SELECT * FROM currentChapter"];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSMutableDictionary *chapterDic = [[NSMutableDictionary alloc]init];
        [chapterDic setObject:[rs stringForColumn:@"id"] forKey:@"id"];
        [chapterDic setObject:[rs stringForColumn:@"chapaterindex"] forKey:@"chapaterindex"];
        [arr addObject:chapterDic];
    }
    
    if ([arr count]==0) {
        [_db executeUpdate:@"insert into currentChapter (id,chapaterindex) values (?,?)",
         [NSNumber numberWithInt:1],
         [NSString stringWithFormat:@"%d",currentChapter]];
    }else
    {
        NSString *sql = [NSString stringWithFormat:@"update currentChapter set chapaterindex = '%@' WHERE ID = %@",
                         [NSString stringWithFormat:@"%d",currentChapter],
                         [NSNumber numberWithInt:1]];
        [_db executeUpdate:sql];
    }
}

-(NSString *)DBCurrentChapter:(NSString *)txtName
{
    [self openDB:txtName];
    FMResultSet *rs = [_db executeQuery:@"SELECT * FROM currentChapter"];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSMutableDictionary *chapterDic = [[NSMutableDictionary alloc]init];
        [chapterDic setObject:[rs stringForColumn:@"id"] forKey:@"id"];
        [chapterDic setObject:[rs stringForColumn:@"chapaterindex"] forKey:@"chapaterindex"];
        [arr addObject:chapterDic];
    }
    if ([arr count]==0) {
        return @"1";
    }else
    {
        return [[arr lastObject] objectForKey:@"chapaterindex"];
    }
}

-(void)DBsaveCurrentPage:(NSString *)txtName withCurrentPage:(NSInteger)currentPage
{
    [self openDB:txtName];
    FMResultSet *rs = [_db executeQuery:@"SELECT * FROM currentPage"];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSMutableDictionary *chapterDic = [[NSMutableDictionary alloc]init];
        [chapterDic setObject:[rs stringForColumn:@"id"] forKey:@"id"];
        [chapterDic setObject:[rs stringForColumn:@"pageindex"] forKey:@"pageindex"];
        [arr addObject:chapterDic];
    }
    
    if ([arr count]==0) {
        [_db executeUpdate:@"insert into currentPage (id,pageindex) values (?,?)",
         [NSNumber numberWithInt:1],
         [NSString stringWithFormat:@"%d",currentPage]];
    }else
    {
        NSString *sql = [NSString stringWithFormat:@"update currentPage set pageindex = '%@' WHERE ID = %@",
                         [NSString stringWithFormat:@"%d",currentPage],
                         [NSNumber numberWithInt:1]];
        [_db executeUpdate:sql];
    }
}

-(NSString *)DBCurrentPage:(NSString *)txtName
{
    [self openDB:txtName];
    FMResultSet *rs = [_db executeQuery:@"SELECT * FROM currentPage"];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSMutableDictionary *chapterDic = [[NSMutableDictionary alloc]init];
        [chapterDic setObject:[rs stringForColumn:@"id"] forKey:@"id"];
        [chapterDic setObject:[rs stringForColumn:@"pageindex"] forKey:@"pageindex"];
        [arr addObject:chapterDic];
    }
    
    if ([arr count]==0) {
        return @"0";
    }else
    {
        return [[arr lastObject] objectForKey:@"pageindex"];
    }
}

-(void)DBsavebookmark:(NSString *)txtName withdata:(NSData*)data
{
    [self deleteTable:txtName];
    [self openDB:txtName];
    [_db executeUpdate:@"insert into bookmark (id,bookmarkdata) values (?,?)",[NSNumber numberWithInt:1],data];
}

-(NSData*)DBbookmakr:(NSString *)txtName
{
    [self openDB:txtName];
    FMResultSet *rs = [_db executeQuery:@"SELECT * FROM bookmark"];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSMutableDictionary *chapterDic = [[NSMutableDictionary alloc]init];
        [chapterDic setObject:[rs stringForColumn:@"id"] forKey:@"id"];
        [chapterDic setObject:[rs dataForColumn:@"bookmarkdata"] forKey:@"bookmarkdata"];
        [arr addObject:chapterDic];
    }

    return [[arr lastObject] objectForKey:@"bookmarkdata"];
}

-(BOOL)deleteTable:(NSString *)tableName
{
    [self openDB:tableName];
    
    if (![_db executeUpdate:@"DROP TABLE bookmark"]) {
        return NO;
    }
    if (![_db executeUpdate:@"DROP TABLE currentChapter"]) {
        return NO;
    }
    if (![_db executeUpdate:@"DROP TABLE currentPage"]) {
        return NO;
    }
    
    return YES;
}

@end
