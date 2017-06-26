//
//  GSChatTableView.h
//  xdfapp
//
//  Created by tony on 2017/6/12.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GSPChatMessage;
@class GSPUserInfo;

@interface LLVChatTableView : UIView
@property (retain,nonatomic)  UITableView *chatTableView;
@property (retain,nonatomic)  GSPUserInfo *userInfo;
@property (nonatomic, strong) NSDictionary *text2keyDic;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)reloadWithMessage:(GSPChatMessage *)message;

- (void)reloadWithVodChats:(NSArray *)chatArray;

- (void)reloadWithVodChatDics:(NSArray *)messages;



/**获取聊天显示视图(table的父视图)*/
+ (instancetype)getChatView;

- (NSString*)chatString:(NSString*)originalStr;

@end
