//
//  ChatViewController.m
//  xchat-ios
//
//  Created by Admin on 2017/9/3.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "ChatViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "XChatToolBar.h"
#import "WebSocketManager.h"
#import "MessageCell.h"
#import "MessageModel.h"
#import <YYModel.h>
#import "AppDelegate.h"
#import "BaseMacros.h"

@interface ChatViewController ()<GetMessageDelegate, XChatToolbarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *messageArr;

@property (nonatomic, assign)NSInteger badgeNumber;

/*!
 @property
 @brief 底部输入控件
 */
@property (strong, nonatomic) UIView *chatToolbar;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.badgeNumber = 0;
    
    [[WebSocketManager share] connect];
    [WebSocketManager share].delegate = self;
    _messageArr = [[NSMutableArray alloc]init];
    
    
    _tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_tableView];
    
    UIGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyBoardHidden)];
    [_tableView addGestureRecognizer:tapgesture];
    
    CGFloat chatbarHeight = [XChatToolBar defaultHeight];
    self.chatToolbar = [[XChatToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - chatbarHeight, self.view.frame.size.width, chatbarHeight)];
    self.chatToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setbadgeNumber) name:@"iconbadgenumber" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:@"username"];
    
    if (userName.length > 0) {
        
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入用户名";
            textField.text = @"飞鱼";
        }];
        UIAlertAction *nextAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@"飞鱼" forKey:@"username"];
            [userDefaults setObject:@"YES" forKey:@"autologin"];
            [[WebSocketManager share]joinRoomWithNickName:alert.textFields[0].text roomId:@"1"];
        }];
        [alert addAction:nextAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)dealloc{
    //移除观察者，Observer不能为nil
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)setChatToolbar:(XChatToolBar *)chatToolbar
{
    [_chatToolbar removeFromSuperview];
    
    _chatToolbar = chatToolbar;
    if (_chatToolbar) {
        [self.view addSubview:_chatToolbar];
    }
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height - _chatToolbar.frame.size.height;
    self.tableView.frame = tableFrame;
    if ([chatToolbar isKindOfClass:[XChatToolBar class]]) {
        [(XChatToolBar *)self.chatToolbar setDelegate:self];
    }
}

- (void)keyBoardHidden {
    
    [self.chatToolbar endEditing:YES];
}


//连接
- (void)connectAction
{
    [[WebSocketManager share] connect];
    
}
//断开连接
- (void)disConnectAction
{
    [[WebSocketManager share] disConnect];
}



//发送消息
- (void)sendMsg:(NSString*)content
{
    [[WebSocketManager share]sendMsgToClientId:@"all" content:content];
}


- (void)pingAction
{
    [[WebSocketManager share]ping];
    
}


- (void)getMessageSuccess:(NSDictionary *)dic{
    MessageModel *msgModel = [MessageModel yy_modelWithDictionary:dic];
    [_messageArr addObject:msgModel];
    DLog(@"%@",_messageArr);

    UIApplication *application = [UIApplication sharedApplication] ;
    [application setApplicationIconBadgeNumber:++_badgeNumber];
    
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    
    //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    if ([msgModel.type isEqualToString:@"login"]) {
        content.title = [NSString localizedUserNotificationStringForKey:@"系统" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"欢迎%@加入聊天室", msgModel.client_name]
                                                             arguments:nil];
    }
    if ([msgModel.type isEqualToString:@"logout"]) {
        content.title = [NSString localizedUserNotificationStringForKey:@"系统" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"%@离开了聊天室", msgModel.from_client_name]
                                                             arguments:nil];
    }
    if ([msgModel.type isEqualToString:@"say"]) {
        content.title = [NSString localizedUserNotificationStringForKey:msgModel.from_client_name arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:msgModel.content
                                                             arguments:nil];
    }
    content.sound = [UNNotificationSound defaultSound];
    
    // 在 alertTime 后推送本地推送
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:1.0 repeats:NO];
    
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"localnotification"
                                                                          content:content trigger:trigger];
    
    //添加推送成功后的处理！
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            
        }
    }];

    
    DLog(@"%@",dic);
    
    
    [_tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView layoutSubviews];
        if(_tableView.contentSize.height>_tableView.bounds.size.height){
            [_tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.bounds.size.height)];
        }
    });
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _messageArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageModel *msgModel = _messageArr[indexPath.row];
    if ([msgModel.type isEqualToString:@"login"] || [msgModel.type isEqualToString:@"logout"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logincell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"logincell"];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        if ([msgModel.type isEqualToString:@"login"]) {
            cell.textLabel.text = [NSString stringWithFormat:@"欢迎%@加入聊天室", msgModel.client_name];
        }else{
            cell.textLabel.text = [NSString stringWithFormat:@"%@离开了聊天室", msgModel.from_client_name];
        }
        return cell;
    }
    
    MessageCell *msgCell = [tableView dequeueReusableCellWithIdentifier:@"msgcell"];
    if (msgCell == nil) {
        msgCell = [[MessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"msgcell"];

    }
    [msgCell refreshCell: _messageArr[indexPath.row]];
    return msgCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = self.messageArr[indexPath.row];
    if ([model.type isEqualToString:@"login"] || [model.type isEqualToString:@"logout"]) {
        return 25;
    }

    CGRect rec =  [model.content boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
    return rec.size.height + 75;
}


#pragma mark - XChatToolbarDelegate

- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - toHeight;
        self.tableView.frame = rect;
    }];
}

- (void)inputTextViewWillBeginEditing:(XChatToolBar *)inputTextView {
    
}

- (void)didSendText:(NSString *)text
{
    [self keyBoardHidden];
    if (text && text.length > 0) {
        [self sendMsg:text];
    }
}

- (BOOL)didInputAtInLocation:(NSUInteger)location {
    
    return NO;
}

- (BOOL)didDeleteCharacterFromLocation:(NSUInteger)location {
    
    return NO;
}

- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext {
    
    [self keyBoardHidden];
}

- (void)setbadgeNumber{
    
    self.badgeNumber = 0;
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:_badgeNumber];
}

@end
