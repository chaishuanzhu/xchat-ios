//
//  ChatViewController.m
//  xchat-ios
//
//  Created by Admin on 2017/9/3.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "ChatViewController.h"

#import "WebSocketManager.h"
#import "MessageCell.h"
#import "MessageModel.h"
#import <YYModel.h>

@interface ChatViewController ()<GetMessageDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *messageArr;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入用户名";
        textField.text = @"飞鱼";
    }];
    UIAlertAction *nextAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[WebSocketManager share]joinRoomWithNickName:alert.textFields[0].text roomId:@"1"];
    }];
    [alert addAction:nextAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    
    NSLog(@"%@",dic);
    
    MessageModel *msgModel = [MessageModel yy_modelWithDictionary:dic];
    [_messageArr addObject:msgModel];
    NSLog(@"%@",_messageArr);
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
    
    MessageCell *msgCell = [tableView dequeueReusableCellWithIdentifier:@"msgcell"];
    if (msgCell == nil) {
        msgCell = [[MessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"msgcell"];
    }
    [msgCell refreshCell: _messageArr[indexPath.row]];
    return msgCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = self.messageArr[indexPath.row];
    CGRect rec =  [model.content boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
    return rec.size.height + 75;
}


#pragma mark - EMChatToolbarDelegate

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

@end
