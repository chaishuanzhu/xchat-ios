//
//  ChatViewController.h
//  xchat-ios
//
//  Created by Admin on 2017/9/3.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XChatToolBar.h"

@interface ChatViewController : UIViewController<XChatToolbarDelegate>

/*!
 @property
 @brief 底部输入控件
 */
@property (strong, nonatomic) UIView *chatToolbar;

@end
