//
//  NSDictionary+JSON.h
//  xchat-ios2
//
//  Created by Admin on 2017/10/15.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

- (NSString *)jsonEncode;

+ (NSDictionary *)jsonDecode:(NSString *)jsonStr;

@end
