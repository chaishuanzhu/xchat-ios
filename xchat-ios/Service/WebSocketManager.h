//
//  WebSocketManager.h
//  xchat-ios
//
//  Created by Admin on 2017/9/3.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    disConnectByServer = 1001,
    disConnectByUser
} DisConnectType;


@protocol GetMessageDelegate <NSObject>

- (void)getMessageSuccess:(NSDictionary *)dic;

@end

@interface WebSocketManager : NSObject

@property (weak, nonatomic)id <GetMessageDelegate> delegate;

+ (instancetype)share;

- (void)connect;

- (void)disConnect;

//初始化心跳
- (void)initHeartBeat;

//取消心跳
- (void)destoryHeartBeat;

- (void)sendMsgToClientId:(NSString *)client_id content:(NSString *)msg;

- (void)joinRoomWithNickName:(NSString *)nickname roomId:(NSString *)room_id;

- (void)ping;


@end
