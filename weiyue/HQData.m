//
//  HQData.m
//  myReader
//
//  Created by hanqiu on 15/3/27.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQData.h"

static HQData *instance;
@implementation HQData

+(HQData*)getInstance
{
    if (instance == nil)
    {
        instance = [[HQData alloc]init];
    }
    return instance;
}


-(id)init
{
    self = [super init];
    _deletelist = [[NSMutableArray alloc] initWithCapacity:0];
    return self;
}

-(void)addDeletelist:(NSString*)object
{
    [_deletelist addObject:object];
}
-(void)removeDeletelist:(NSString *)object
{
    [_deletelist removeObject:object];
}
@end
