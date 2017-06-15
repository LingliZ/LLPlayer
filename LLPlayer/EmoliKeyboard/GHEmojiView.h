//
//  GHEmojiView.h
//  GHEmojiKeyboard
//
//  Created by Gaojin Hsu on 4/25/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import <UIKit/UIKit.h>

//声明表情对应的block,用于把点击的表情的图片和图片信息传到上层视图
typedef void (^EmojiBlock) (UIImage *emojiImage, NSString *emojiText);

@interface GHEmojiView : UIView

@property (nonatomic, strong)NSString *emojiText;

@property (nonatomic, strong)UIImage *emojiImage;

- (void)setEmojiImage:(UIImage *)emojiImage EmojiText:(NSString *)emojiText;

- (void)setEmojiBlock:(EmojiBlock)block;


@end
