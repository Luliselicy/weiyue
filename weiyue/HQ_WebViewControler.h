//
//  HQ_WebViewControler.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

@interface HQ_WebViewControler : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    NSString *_selectString;
    
}

- (id)initWithSelectString:(NSString *)selectString;

@end
