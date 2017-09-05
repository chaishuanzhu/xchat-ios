//
//  Json.h
//  xchat-ios
//
//  Created by Admin on 2017/9/3.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Json : NSObject

+ (NSString *)jsonEncode:(NSDictionary *)dic;

+ (NSDictionary *)jsonDncode:(NSString *)jsonString;

@end
