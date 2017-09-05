//
//  MessageCell.h
//  xchat-ios
//
//  Created by Admin on 2017/9/3.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"
@interface MessageCell : UITableViewCell

- (void)refreshCell:(MessageModel *)model; // 安装我们的cell

@end
