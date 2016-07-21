//
//  HQ_Paging.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import "HQ_Paging.h"

#import <CoreText/CoreText.h>
#include <vector>
#include <fstream>
#include <iostream>

#define CHAR_PER_LOAD 50000

using namespace std;

@interface HQ_Paging ()

@end

@implementation HQ_Paging
{
    vector<NSUInteger> _pageOffsets;
}


- (void)paginate
{

    _pageOffsets.clear();
    
    NSString *buffer = [self subStringWithRange:NSMakeRange(0, CHAR_PER_LOAD)];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString  alloc] initWithString:buffer];
    buffer = nil; // 马上释放
    
    NSDictionary *strAttr = [self stringAttrWithFont:self.contentFont];
    [attrString setAttributes:strAttr range:NSMakeRange(0, attrString.length)];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrString);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, _textRenderSize.width, _textRenderSize.height), NULL);
    
    int currentOffset = 0;
    int currentInnerOffset = 0;
    BOOL hasMorePages = YES;
    
    int preventDeadLoopSign = currentOffset;
    int samePlaceRepeatCount = 0;
    
    while (hasMorePages) {
        if (preventDeadLoopSign == currentOffset) {
            
            ++samePlaceRepeatCount;
            
        } else {
            
            samePlaceRepeatCount = 0;
        }
        
        if (samePlaceRepeatCount > 1) {
            if (_pageOffsets.size() == 0) {
                
                _pageOffsets.push_back(currentOffset);
                
            } else {
                
                NSUInteger lastOffset = _pageOffsets.back();
                
                if (lastOffset != currentOffset) {
                    
                    _pageOffsets.push_back(currentOffset);
                }
            }
            break;
        }
        
        _pageOffsets.push_back(currentOffset);
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(currentInnerOffset, 0), path, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        
        if ((range.location + range.length) != attrString.length) {
            
            currentOffset += range.length;
            currentInnerOffset += range.length;
            
        } else if ((range.location + range.length) == attrString.length && (currentOffset + range.length) != [_contentText length]) {
            CFRelease(frame); frame = NULL;
            CFRelease(frameSetter);
            
            _pageOffsets.pop_back();
            
            buffer = [self subStringWithRange:NSMakeRange(currentOffset, CHAR_PER_LOAD)];
            attrString = [[NSMutableAttributedString alloc] initWithString:buffer];
            [attrString setAttributes:strAttr range:NSMakeRange(0, attrString.length)];
            buffer = nil;
            
            currentInnerOffset = 0;
            frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrString);
        } else {
            hasMorePages = NO;
        }
        if (frame) CFRelease(frame);
    }
    
    CGPathRelease(path);
    CFRelease(frameSetter);
    
}

- (NSUInteger)pageCount {
    
    return _pageOffsets.size();
}


- (NSString *)stringOfPage:(NSUInteger)page {
    
    if (page >= [self pageCount]) return @"";
    
    NSUInteger head = _pageOffsets[page];
    
    NSUInteger tail = _contentText.length;
    if (page+1 < [self pageCount]) {
        
        tail = _pageOffsets[page+1];
    }
    
    return [self subStringWithRange:NSMakeRange(head, tail-head)];
}


- (NSString *)subStringWithRange:(NSRange)range
{
    if (range.location == NSNotFound) return @"";
    
    NSUInteger head = range.location;
    if (head >= _contentText.length) return @"";
    
    NSUInteger tail = (range.location + range.length);
    tail = tail > _contentText.length ? _contentText.length : tail;
    
    if ((NSUInteger)(tail - head) == 4294602370) {
        
        return @"";
    }
    
    return [_contentText substringWithRange:NSMakeRange(head, tail - head)];
}

- (NSRange)rangeOfPage:(NSUInteger)page {
    
    if (page >= _pageOffsets.size()) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    if (page < _pageOffsets.size() - 1) {
        return NSMakeRange(_pageOffsets[page], _pageOffsets[page + 1] - _pageOffsets[page]);
    }
    
    return NSMakeRange(_pageOffsets[page], _contentText.length - _pageOffsets[page]);
}

- (NSDictionary *)stringAttrWithFont:(NSUInteger )fontSize
{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = font.pointSize / 2;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font};
}

@end
