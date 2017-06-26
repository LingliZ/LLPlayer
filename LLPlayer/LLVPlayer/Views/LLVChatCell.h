//
//  LLChatCell.h
//  xdfapp
//
//  Created by tony on 2017/6/13.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LLVChatCellModel;

@interface LLVChatCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *key2fileDic;
@property (strong, nonatomic)  NSDictionary *dic3;
@property (assign, nonatomic)  CGFloat       cellHeight;
/* 数据源 */
@property (nonatomic, strong) LLVChatCellModel *model;

/**
 初始化cell
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
