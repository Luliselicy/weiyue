//
//  HQ_ContantFile.h
//  weiyue
//
//  Created by hanqiu on 15/5/3.
//  Copyright (c) 2015年 hanqiu. All rights reserved.
//

#ifndef weiyue_HQ_ContantFile_h
#define weiyue_HQ_ContantFile_h

#define OPEN @"open"
#define SAVEPAGE @"savePage"
#define SAVETHEME @"saveTheme"
#define SAVETIME @"saveTime"
#define offSet_x 20
#define offSet_y 40
#define FONT_SIZE @"FONT_SIZE"
#define kBottomBarH 200

#define kScreenW [UIScreen mainScreen].bounds.size.width


#define DELAYEXECUTE(delayTime,func) (dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{func;}))

#endif
