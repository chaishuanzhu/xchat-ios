//
//  BaseMacros.h
//  xchat-ios
//
//  Created by Admin on 2017/9/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#ifndef BaseMacros_h
#define BaseMacros_h


#ifdef DEBUG
#define DDLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define DDLog(...)
#endif

#endif /* BaseMacros_h */
