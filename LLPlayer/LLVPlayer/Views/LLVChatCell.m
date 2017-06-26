//
//  LLChatCell.m
//  xdfapp
//
//  Created by tony on 2017/6/13.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#define ContentLabelViewTag 999

#import "LLVChatCellModel.h"

#import "LLVChatCell.h"
#import <PlayerSDK/PlayerSDK.h>

#import "LLVColorTool.h"
#import "LLVPublicTool.h"
#import "LLVMarkupParser.h"
#import "LLVGIFImageView.h"
#import "NSAttributedString+LLVAttributes.h"
#import "LLVAttributedLabel.h"

#import "UIImageView+LLV_HttpImageView.h"

@interface LLVChatCell()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *contentButton;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation LLVChatCell{
    GSPChatMessage *messageInfo;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self seutpSubViews];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)seutpSubViews
{
    _titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_titleLabel];
    
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_iconImageView];
    
    _contentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_contentButton];
}

#pragma mark - setter method
- (void)setModel:(LLVChatCellModel *)model
{
    if(_model != model){
        _model = model;
        
        //标题
        _titleLabel.frame = _model.titleFrame;
        _titleLabel.attributedText = _model.titleAttString;
        
        //头像
        _iconImageView.frame = _model.iconFrame;
        _iconImageView.layer.cornerRadius = _iconImageView.bounds.size.height/2.0;
        [_iconImageView LLV_setImageWithUrl:@"http://www.iconpng.com/png/flatastic1/user-red.png" placeholderImage:[UIImage imageNamed:@"ll_chat_user_icon"]];
        
        //消息内容
        LLVAttributedLabel *contentLabel = (LLVAttributedLabel*)[self.contentView viewWithTag:ContentLabelViewTag];
        if (contentLabel) {
            [contentLabel removeFromSuperview];
            contentLabel = nil;
        }
        contentLabel  = [[LLVAttributedLabel alloc]initWithFrame:_model.contentFrame];
        contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        contentLabel.tag = ContentLabelViewTag;
        contentLabel.linkColor = nil;//链接的颜色，默认蓝色
        contentLabel.underlineLinks = NO;//不显示链接下面的线
        [self.contentView addSubview:contentLabel];
        
        [contentLabel setNeedsDisplay];
        [contentLabel setAttString:_model.contentAttString withImages:_model.images];
        
        [contentLabel.layer display];
        
        [self drawImageView:contentLabel];
        
        //聊天背景
        UIImage  *normalImage = [UIImage imageNamed:_model.chatBackImage];
        CGFloat norWidth =  normalImage.size.width;
        CGFloat norHeight = normalImage.size.height;
        [self.contentButton setBackgroundImage:[normalImage resizableImageWithCapInsets:UIEdgeInsetsMake(norHeight/2, norWidth/2, norHeight/2, norWidth/2)] forState:UIControlStateNormal];
        [self.contentButton setBackgroundImage:[normalImage resizableImageWithCapInsets:UIEdgeInsetsMake(norHeight/2, norWidth/2, norHeight/2, norWidth/2)] forState:UIControlStateHighlighted];
        _contentButton.frame = _model.chatBackImageFrame;
    }
}

-(void)drawImageView:(LLVAttributedLabel*)label
{
    @synchronized (self) {
        for (NSArray *info in label.imageInfoArr) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:[info objectAtIndex:0] ofType:nil];
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            LLVGIFImageView *imageView = [[LLVGIFImageView alloc] initWithGIFData:data];
            imageView.frame = CGRectFromString([info objectAtIndex:2]);
            [label addSubview:imageView];//label内添加图片层
            [label bringSubviewToFront:imageView];
            imageView = nil;
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
