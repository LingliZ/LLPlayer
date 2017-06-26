//
//  LLVEmojiCollectionView.h
//  LLVEmojiKeyboard
//
//  Created by tony on 2017/6/19.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EmojiCollectionViewBlock) (UIImage *emojiImage, NSString *emojiText);

@interface LLVEmojiCollectionView : UIView

- (id)initWithFrame:(CGRect)frame emijiPlistFileName:(NSString*)plistFileName inBundle:(NSBundle*)bundle;

- (void)setEmojiCollectionViewBlock:(EmojiCollectionViewBlock)block;

@end
