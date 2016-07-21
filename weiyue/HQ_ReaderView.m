//
//  HQ_ReaderView.m
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//


#import "HQ_ReaderView.h"
#import <CoreText/CoreText.h>
#import "HQ_ContantFile.h"
#import "HQ_CommonManager.h"
#import <AVFoundation/AVSpeechSynthesis.h>


#define kEpubView_H self.frame.size.height
#define kItemCopy           @"复制"
#define kItemCiBa           @"词霸"
#define kItemRead           @"朗读"

@implementation HQ_ReaderView
{
    CTFrameRef _ctFrame;
    NSRange selectedRange;
    
    UIGestureRecognizer *panRecognizer;
    UITapGestureRecognizer *tapRecognizer;
    UILongPressGestureRecognizer *longRecognizer;
    
}

- (void)dealloc
{
    if (_ctFrame != NULL) {
        CFRelease(_ctFrame);
    }
}

#pragma mark - 初始化一些手势等
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressAction:)];
        longRecognizer.enabled = YES;
        [self addGestureRecognizer:longRecognizer];
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapAction:)];
        tapRecognizer.enabled = NO;
        [self addGestureRecognizer:tapRecognizer];
        
        
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(PanAction:)];
        [self addGestureRecognizer:panRecognizer];
        panRecognizer.enabled = NO;
        
    }
    return self;
}



#pragma mark - 绘制相关方法

- (void)drawRect:(CGRect)rect
{
    if (!_ctFrame) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGAffineTransform transform = CGAffineTransformMake(1,0,0,-1,0,self.bounds.size.height);
    CGContextConcatCTM(context, transform);
    

    
    [self showSelectRect:selectedRange];
    [self showCursor];
    
    CTFrameDraw(_ctFrame, context);
}




- (NSDictionary *)coreTextAttributes
{
    UIFont *font_ = [UIFont systemFontOfSize:self.font];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = font_.pointSize / 2;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    NSDictionary *dic = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font_};
    return dic;
}


- (void)render
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString  alloc] initWithString:self.text];
    
    [attrString setAttributes:self.coreTextAttributes range:NSMakeRange(0, attrString.length)];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrString);
    CGPathRef path = CGPathCreateWithRect(self.bounds, NULL);
    if (_ctFrame != NULL) {
        CFRelease(_ctFrame), _ctFrame = NULL;
    }
    _ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    
    CFRelease(path);
    CFRelease(frameSetter);
}

- (CTFrameRef)getCTFrame
{
    return _ctFrame;
}



#pragma mark - 计算选择区域
- (void)showSelectRect:(NSRange)selectRect{
    
    if (selectRect.length == 0 || selectRect.location == NSNotFound) {
        return;
    }
    
    NSMutableArray *pathRects = [[NSMutableArray alloc] init];
    NSArray *lines = (NSArray*)CTFrameGetLines([self getCTFrame]);
    CGPoint *origins = (CGPoint*)malloc([lines count] * sizeof(CGPoint));
    CTFrameGetLineOrigins([self getCTFrame], CFRangeMake(0,0), origins);
    
    for (int i = 0; i < lines.count; i ++) {
        CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange range = NSMakeRange(lineRange.location==kCFNotFound ? NSNotFound : lineRange.location, lineRange.length);
        NSRange intersection = [self rangeIntersection:range withSecond:selectRect];
        if (intersection.length > 0) {
            
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, intersection.location, NULL);
            
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, intersection.location + intersection.length, NULL);
            CGPoint origin = origins[i];
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            CGRect selectionRect = CGRectMake(origin.x + xStart, origin.y - descent, xEnd - xStart, ascent + descent);
            [pathRects addObject:NSStringFromCGRect(selectionRect)];
        }
    }
    free(origins);
    [self drawPathFromRects:pathRects];
    
}

#pragma mark- 画背景色
- (void)drawPathFromRects:(NSMutableArray*)array
{
    if (array==nil || [array count] == 0)
    {
        return;
    }
    
    CGMutablePathRef _path = CGPathCreateMutable();
    
    [[UIColor colorWithRed:228/255.0 green:100/255.0 blue:166/255.0 alpha:0.6]setFill];
    
    
    for (int i = 0; i < [array count]; i++) {
        
        CGRect firstRect = CGRectFromString([array objectAtIndex:i]);
        CGPathAddRect(_path, NULL, firstRect);
        
    }
    
    [self resetCursor:array];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, _path);
    CGContextFillPath(ctx);
    CGPathRelease(_path);
}

#pragma mark- 重新设置光标的位置
- (void)resetCursor:(NSMutableArray*)rectArray{
    
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CGPoint leftCursorPoint = CGRectFromString([rectArray objectAtIndex:0]).origin;
    leftCursorPoint = CGPointApplyAffineTransform(leftCursorPoint, transform);
    _leftCursor.setupPoint = leftCursorPoint;
    
    CGPoint rightCursorPoint = CGRectFromString([rectArray lastObject]).origin;
    rightCursorPoint.x = rightCursorPoint.x + CGRectFromString([rectArray lastObject]).size.width;
    rightCursorPoint = CGPointApplyAffineTransform(rightCursorPoint, transform);
    _rightCursor.setupPoint = rightCursorPoint;
    
}

#pragma mark - 初始化光标
- (void)showCursor{
    
    if (selectedRange.length == 0 || selectedRange.location == NSNotFound || _rightCursor != nil || _leftCursor != nil) {
        return;
    }
    
    [self removeCursor];
    _leftCursor = [[HQ_CursorView alloc] initWithType:CursorLeft andHeight:self.font byDrawColor:[UIColor blueColor]];
    _rightCursor = [[HQ_CursorView alloc] initWithType:CursorRight andHeight:self.font byDrawColor:[UIColor blueColor]];
    [self addSubview:_leftCursor];
    [self addSubview:_rightCursor];
    
    [self setNeedsDisplay];
}



#pragma mark - 长按手势
- (void)LongPressAction:(UILongPressGestureRecognizer *)longPress{
    
    CGPoint point = [longPress locationInView:self];
    
    if (longPress.state == UIGestureRecognizerStateBegan ||
        longPress.state == UIGestureRecognizerStateChanged){
        [_delegate shutOffGesture:YES];
        [_delegate hideSettingToolBar];
        CFIndex index = [self getTouchIndexWithTouchPoint:point];
        
        if (index != -1 && index < self.text.length) {
            NSRange range = [self characterRangeAtIndex:index doFrame:[self getCTFrame]];
            selectedRange = NSMakeRange(range.location, range.length);
            
        }
        self.magnifierView.touchPoint = point;
    }else{
        
        [self removeMaginfierView];
        [self showCursor];
        if (selectedRange.length == 0) {
            panRecognizer.enabled = NO;
        }else{
            [self showMenuUI];
        }
        tapRecognizer.enabled = YES;
    }
    
    if (selectedRange.length != 0) {
        panRecognizer.enabled = YES;
    }
}


#pragma mark -平移拖动
- (void)PanAction:(UIPanGestureRecognizer *)panGes{
    
    CGPoint point = [panGes locationInView:self];
    
    if (panGes.state == UIGestureRecognizerStateBegan) {
        
        if (_leftCursor && CGRectContainsPoint(CGRectInset(_leftCursor.frame, -25, -10), point)) {
            _leftCursor.tag = 1;
            
        } else if (_rightCursor && CGRectContainsPoint(CGRectInset(_rightCursor.frame, -25, -10), point)) {
            _rightCursor.tag = 1;
            
        }else{
            [self removeMaginfierView];
        }
    }else if (panGes.state == UIGestureRecognizerStateChanged){
        
        [self hideMenuUI];
        
        CFIndex index = [self getTouchIndexWithTouchPoint:point];
        
        if (index == -1) {
            return;
        }
        if (_leftCursor.tag == 1 && index < selectedRange.length + selectedRange.location) {
            
            selectedRange.length = selectedRange.location - index + selectedRange.length;
            selectedRange.location = index;
            self.magnifierView.touchPoint = point;
            
        } else if (_rightCursor.tag == 1 && index > selectedRange.location) {
            
            selectedRange.location = selectedRange.location;
            selectedRange.length =  index - selectedRange.location;
            self.magnifierView.touchPoint = point;
            
        }
        
        
    }else if (panGes.state == UIGestureRecognizerStateEnded ||
              panGes.state == UIGestureRecognizerStateCancelled) {
        
        _leftCursor.tag = 0;
        _rightCursor.tag = 0;
        [self removeMaginfierView];
        if (selectedRange.length == 0) {
            panRecognizer.enabled = NO;
            
        }else{
            [self showMenuUI];
        }
        
    }
    [self setNeedsDisplay];
}

#pragma mark - 隐藏menu
- (void)hideMenuUI {
    if ([self resignFirstResponder]) {
        UIMenuController *theMenu = [UIMenuController sharedMenuController];
        [theMenu setMenuVisible:NO animated:YES];
    }
}

#pragma mark - 显示menu
- (void)showMenuUI{
    
    longRecognizer.enabled = NO;
    if ([self becomeFirstResponder]) {
        CGRect selectedRect = [self getMenuRect];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        
        UIMenuItem *menuItemCopy = [[UIMenuItem alloc]
                                    initWithTitle:kItemCopy
                                    action:@selector(copyword:)];
        

        UIMenuItem *menuItemCiBa = [[UIMenuItem alloc] initWithTitle:kItemCiBa action:@selector(ciBa:)];
        UIMenuItem *menuItmeRead = [[UIMenuItem alloc] initWithTitle:kItemRead action:@selector(readText:)];
        NSArray *mArray = [NSArray arrayWithObjects:
                           menuItemCopy,
                           menuItemCiBa,
                           menuItmeRead,
                           nil];
        [menuController setMenuItems:mArray];
        
        
        CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
        selectedRect = CGRectApplyAffineTransform(selectedRect, transform);
        
        [menuController setTargetRect:selectedRect inView:self];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (CGRect )getMenuRect{
    
    if (selectedRange.length == 0 || selectedRange.location == NSNotFound) {
        return CGRectZero;
    }
    
    NSMutableArray *pathRects = [[NSMutableArray alloc] init];
    NSArray *lines = (NSArray*)CTFrameGetLines([self getCTFrame]);
    CGPoint *origins = (CGPoint*)malloc([lines count] * sizeof(CGPoint));
    CTFrameGetLineOrigins([self getCTFrame], CFRangeMake(0,0), origins);
    
    for (int i = 0; i < lines.count; i ++) {
        CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange range = NSMakeRange(lineRange.location==kCFNotFound ? NSNotFound : lineRange.location, lineRange.length);
        NSRange intersection = [self rangeIntersection:range withSecond:selectedRange];
        if (intersection.length > 0) {
            
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, intersection.location, NULL);
            
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, intersection.location + intersection.length, NULL);
            CGPoint origin = origins[i];
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            CGRect selectionRect = CGRectMake(origin.x + xStart, origin.y - descent, xEnd - xStart, ascent + descent);
            [pathRects addObject:NSStringFromCGRect(selectionRect)];
        }
    }
    free(origins);
    
    return  CGRectFromString([pathRects firstObject]);
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyword:) || action == @selector(ciBa:) || action == @selector(readText:)) {
        return YES;
    }
    return NO;
}

- (void)resetting{
    
    selectedRange.location = 0;
    selectedRange.length = 0;
    [self removeCursor];
    [self hideMenuUI];
    [self setNeedsDisplay];
    
    panRecognizer.enabled = NO;
    tapRecognizer.enabled = NO;
    longRecognizer.enabled = YES;
    
}

- (void)readText:(id)sender{
    
    [_delegate shutOffGesture:NO];
    
    NSString *readText = [NSString stringWithFormat:@"%@",[self.text substringWithRange:NSMakeRange(selectedRange.location, selectedRange.length)]];
    
    AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:readText];
    utterance.rate = 0.2;
    utterance.pitchMultiplier = 0.5;
    [av speakUtterance:utterance];
    [self resetting];
}


- (void)ciBa:(id)sender{
    
    [_delegate shutOffGesture:NO];
    NSString *ciBaString = [NSString stringWithFormat:@"%@",[self.text substringWithRange:NSMakeRange(selectedRange.location, selectedRange.length)]];
    [_delegate ciBa:ciBaString];
    [self resetting];
}


#pragma mark - copy
- (void)copyword:(id)sender{
    
    [_delegate shutOffGesture:NO];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:[NSString stringWithFormat:@"%@",[self.text substringWithRange:NSMakeRange(selectedRange.location, selectedRange.length)]]];
    
    [self resetting];
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark -单击手势
- (void)TapAction:(UITapGestureRecognizer *)doubleTap{
    
    [_delegate shutOffGesture:NO];
    selectedRange.location = 0;
    selectedRange.length = 0;
    [self removeCursor];
    [self hideMenuUI];
    [self setNeedsDisplay];
    
    panRecognizer.enabled = NO;
    tapRecognizer.enabled = NO;
    longRecognizer.enabled = YES;
}


#pragma mark -移除放大镜
- (void)removeMaginfierView {
    
    if (_magnifierView) {
        [_magnifierView removeFromSuperview];
        _magnifierView = nil;
    }
}

#pragma mark -移除光标
- (void)removeCursor{
    
    if (_leftCursor) {
        [_leftCursor removeFromSuperview];
        _leftCursor = nil;
    }
    if (_rightCursor) {
        [_rightCursor removeFromSuperview];
        _rightCursor = nil;
    }
    
}


#pragma mark -根据用户手指的坐标获得 手指下面文字在整页文字中的index
- (CFIndex)getTouchIndexWithTouchPoint:(CGPoint)touchPoint{
    
    CTFrameRef textFrame = [self getCTFrame];
    NSArray *lines = (NSArray*)CTFrameGetLines(textFrame);
    if (!lines) {
        return -1;
    }
    CFIndex index = -1;
    NSInteger lineCount = [lines count];
    CGPoint *origins = (CGPoint*)malloc(lineCount * sizeof(CGPoint));
    if (lineCount != 0) {
        CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), origins);
        
        for (int i = 0; i < lineCount; i++){
            
            CGPoint baselineOrigin = origins[i];
            baselineOrigin.y = CGRectGetHeight(self.frame) - baselineOrigin.y;
            
            CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
            CGFloat ascent, descent;
            CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            
            CGRect lineFrame = CGRectMake(baselineOrigin.x, baselineOrigin.y - ascent, lineWidth, ascent + descent);
            if (CGRectContainsPoint(lineFrame, touchPoint)){
                index = CTLineGetStringIndexForPosition(line, touchPoint);
                
            }
        }
        
    }
    free(origins);
    return index;
    
}

#pragma mark - 中文字典串
- (NSRange)characterRangeAtIndex:(NSInteger)index doFrame:(CTFrameRef)frame
{
    __block NSArray *lines = (NSArray*)CTFrameGetLines(_ctFrame);
    NSInteger count = [lines count];
    __block NSRange returnRange = NSMakeRange(NSNotFound, 0);
    
    for (int i=0; i < count; i++) {
        
        __block CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        CFRange cfRange = CTLineGetStringRange(line);
        CFRange cfRange_Next = CFRangeMake(0, 0);
        if (i < count - 1) {
            __block CTLineRef line_Next = (__bridge CTLineRef)[lines objectAtIndex:i+1];
            cfRange_Next = CTLineGetStringRange(line_Next);
        }
        
        NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length == kCFNotFound ? 0 : cfRange.length);
        
        if (index >= range.location && index <= range.location+range.length) {
            
            if (range.length > 1) {
                NSRange newRange = NSMakeRange(range.location, range.length + cfRange_Next.length);
                [self.text enumerateSubstringsInRange:newRange options:NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop){
                    
                    if (index - subStringRange.location <= subStringRange.length&&index - subStringRange.location!=0) {
                        returnRange = subStringRange;
                        
                        if (returnRange.length <= 2 && self.text.length > 1) {
                            returnRange.length = 2;
                        }
                        *stop = YES;
                        
                    }
                    
                }];
                
            }
            
        }
    }
    
    return returnRange;
}

- (HQ_MagnifiterView *)magnifierView {
    
    if (_magnifierView == nil) {
        _magnifierView = [[HQ_MagnifiterView alloc] init];
        if (_magnifiterImage == nil) {
            _magnifierView.backgroundColor = [UIColor whiteColor];
        }else{
            _magnifierView.backgroundColor = [UIColor colorWithPatternImage:_magnifiterImage];
        }
        _magnifierView.viewToMagnify = self;
        [self addSubview:_magnifierView];
    }
    return _magnifierView;
}

#pragma mark- Range区域
- (NSRange)rangeIntersection:(NSRange)first withSecond:(NSRange)second
{
    NSRange result = NSMakeRange(NSNotFound, 0);
    if (first.location > second.location)
    {
        NSRange tmp = first;
        first = second;
        second = tmp;
    }
    if (second.location < first.location + first.length)
    {
        result.location = second.location;
        NSUInteger end = MIN(first.location + first.length, second.location + second.length);
        result.length = end - result.location;
    }
    return result;
}

@end

