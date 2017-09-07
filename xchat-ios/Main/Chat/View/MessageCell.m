//
//  MessageCell.m
//  xchat-ios
//
//  Created by Admin on 2017/9/3.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "MessageCell.h"

@interface MessageCell()

@property (nonatomic, strong)UIImageView *imgView;

@property (nonatomic, strong)UILabel *nameLabel;

@property (nonatomic,strong) UIImageView *backView; // 气泡

@property (nonatomic,strong) UILabel *contentLabel; // 气泡内文本

@end

@implementation MessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imgView = [[UIImageView alloc]init];
        [self.contentView addSubview:_imgView];
        
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.font = [UIFont systemFontOfSize:19];
        [self.contentView addSubview:_nameLabel];
        
        self.backView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.backView];
        
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:17];
        [self.backView addSubview:_contentLabel];
    }
    return self;
}

- (void)refreshCell:(MessageModel *)model
{
    // 首先计算文本宽度和高度
    CGRect rec = [model.content boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
    // 气泡
    UIImage *image = nil;
    // 头像
    UIImage *headImage = nil;
    // 模拟左边
    //    if (!model.isRight)
    // 当输入只有一个行的时候高度就是20多一点
    self.imgView.frame = CGRectMake(10, 10, 50, 50);
    self.nameLabel.frame = CGRectMake(70, 10, 200, 30);
    self.backView.frame = CGRectMake(60, 35, rec.size.width + 40, rec.size.height + 30);
    image = [UIImage imageNamed:@"AV_chat_recive_msg"];
    headImage = [UIImage imageNamed:@"head.JPG"];
    //    }
    //    else // 模拟右边
    //    {
    //        self.imgView.frame = CGRectMake(375 - 60, rec.size.height - 18, 50, 50);
    //        self.backView.frame = CGRectMake(375 - 60 - rec.size.width - 20, 10, rec.size.width + 20, rec.size.height + 20);
    //        image = [UIImage imageNamed:@"bubbleMine"];
    //        headImage = [UIImage imageNamed:@"naruto@3x"];
    //        //        image.leftCapWidth
    //    }
    // 拉伸图片 参数1 代表从左侧到指定像素禁止拉伸，该像素之后拉伸，参数2 代表从上面到指定像素禁止拉伸，该像素以下就拉伸
    image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
    self.backView.image = image;
    self.imgView.image = headImage;
    self.nameLabel.text = model.from_client_name;
    // 文本内容的frame
    //    self.contentLabel.frame = CGRectMake(model.isRight ? 5 : 13, 5, rec.size.width, rec.size.height);
    self.contentLabel.frame = CGRectMake(20, 15, rec.size.width, rec.size.height);
    self.contentLabel.text = model.content;
}


@end
