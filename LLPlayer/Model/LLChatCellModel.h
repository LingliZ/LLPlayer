//
//  LLChatCellModel.h
//  xdfapp
//
//  Created by tony on 2017/6/12.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//


#import <Foundation/Foundation.h>
@class GSPChatMessage;

@interface LLChatCellModel : NSObject
//  cell上面的聊天信息
@property (nonatomic, retain) GSPChatMessage *cellMessage;
@property (strong, nonatomic)  NSDictionary *key2fileDic;
@property (strong, nonatomic)  NSString *chatBackImage;//聊天的背景图片

@property (nonatomic, assign) CGFloat marginX;
@property (nonatomic, assign) CGFloat marginY;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *contentFont;

//  计算出来的cell高度
@property (assign, nonatomic)  CGFloat cellHeight;

@property (assign, nonatomic)  CGFloat cellWidth;

@property (assign, nonatomic)  CGRect iconFrame;

@property (assign, nonatomic)  CGRect titleFrame;

@property (assign, nonatomic)  CGRect contentFrame;

@property (assign, nonatomic)  CGRect chatBackImageFrame;

@property (strong, nonatomic)  NSAttributedString *titleAttString;
@property (strong, nonatomic)  NSMutableAttributedString *contentAttString;
@property (strong, nonatomic)  NSMutableArray* images;

/**
 *  角色
 */
@property (nonatomic, assign) NSUInteger chatRole;// 1其他人 2用户自己 3讲师

//布局
- (void)layoutCellFrame;

@end
