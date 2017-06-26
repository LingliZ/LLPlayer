//
//  LLVInputToolView.h
//  LLVEmojiKeyboard
//
//  Created by tony on 2017/6/19.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLVEmojiCollectionView.h"


@protocol LLVToolViewDelegate <NSObject>

- (void)sendMessage:(NSString *)content;

@end


@interface LLVInputToolView : UIView


- (id)initWithParentFrame:(CGRect)parentFrame emojiPlistFileName:(NSString*)fileName inBundle:(NSBundle*)bundle;

- (id)initWithParentFrame:(CGRect)parentFrame;

- (void)endEditting;

@property (nonatomic, weak) id <LLVToolViewDelegate> delegate;

@property (nonatomic, strong) UITextView *inputTextView;

@property (nonatomic, strong )UIButton *emojiButton;

@property (nonatomic,strong) UIButton *sendButton;

@end
