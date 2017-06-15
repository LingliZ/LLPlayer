//
//  GHInputToolView.h
//  GHEmojiKeyboard
//
//  Created by Gaojin Hsu on 4/25/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHEmojiCollectionView.h"


@protocol GHToolViewDelegate <NSObject>

- (void)sendMessage:(NSString *)content;

@end


@interface GHInputToolView : UIView


- (id)initWithParentFrame:(CGRect)parentFrame emojiPlistFileName:(NSString*)fileName inBundle:(NSBundle*)bundle;

- (id)initWithParentFrame:(CGRect)parentFrame;

- (void)endEditting;

@property (nonatomic, weak) id <GHToolViewDelegate> delegate;

@property (nonatomic, strong) UITextView *inputTextView;

@property (nonatomic, strong )UIButton *emojiButton;

@property (nonatomic,strong) UIButton *sendButton;

@end
