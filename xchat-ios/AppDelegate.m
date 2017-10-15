//
//  AppDelegate.m
//  xchat-ios
//
//  Created by Admin on 2017/8/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "AppDelegate.h"
#import "WebSocketManager.h"
#import "ChatViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "BaseMacros.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[WebSocketManager share]connect];
    
    // 注册
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            
            [[UIApplication sharedApplication]registerForRemoteNotifications];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册成功" message:nil delegate:nil cancelButtonTitle:@"👌" otherButtonTitles:nil, nil];
//            [alert show];
        }
    }];
    center.delegate = self;

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    UINavigationController *naVC = [[UINavigationController alloc]initWithRootViewController:chatVC];
    self.window.rootViewController = naVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"iconbadgenumber" object:nil];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {

    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    DDLog(@"regisger success:%@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error{
    
    DDLog(@"%@",error);
}


/*APP 在前台时 收到通知*/
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {

}

/*APP 收到通知*/
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {

}


@end
