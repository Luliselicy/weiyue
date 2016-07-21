//
//  HQ_Mark.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQ_Mark.h"

#define kMarkChapter    @"kMarkChapter"
#define kMarkRange      @"kMarkRange"
#define kMarkContent    @"kMarkContent"
#define kMarkTime       @"kMarkTime"

@implementation HQ_Mark

@synthesize markChapter;
@synthesize markRange;
@synthesize markContent;
@synthesize markTime;

- (void)encodeWithCoder:(NSCoder *)encoder{
    
    [encoder encodeObject:self.markChapter forKey:kMarkChapter];
    [encoder encodeObject:self.markRange   forKey:kMarkRange];
    [encoder encodeObject:self.markContent forKey:kMarkContent];
    [encoder encodeObject:self.markTime    forKey:kMarkTime];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        
        self.markChapter = [decoder decodeObjectForKey:kMarkChapter];
        self.markRange   = [decoder decodeObjectForKey:kMarkRange];
        self.markContent = [decoder decodeObjectForKey:kMarkContent];
        self.markTime    = [decoder decodeObjectForKey:kMarkTime];
        
    }
    return self;
}


@end
