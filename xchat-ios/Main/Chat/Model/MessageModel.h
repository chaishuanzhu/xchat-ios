//
//  MessageModel.h
//  xchat-ios
//
//  Created by Admin on 2017/9/3.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property(nonatomic, copy)NSString *type;

@property(nonatomic, copy)NSString *client_id;

@property(nonatomic, copy)NSArray *client_list;

@property(nonatomic, copy)NSString *client_name;

@property(nonatomic, copy)NSString *from_client_id;

@property(nonatomic, copy)NSString *from_client_name;

@property(nonatomic, copy)NSString *to_client_id;

@property(nonatomic, copy)NSString *content;

@property(nonatomic, copy)NSString *time;

@end
