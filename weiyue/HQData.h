//
//  HQData.h
//  myReader
//
//  Created by hanqiu on 15/3/27.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define Reader [HQData getInstance]
@interface HQData : NSObject


@property(nonatomic,retain) NSMutableArray *deletelist;

+(HQData*)getInstance;

-(void)addDeletelist:(NSString*)object;
-(void)removeDeletelist:(NSString *)object;
@end
