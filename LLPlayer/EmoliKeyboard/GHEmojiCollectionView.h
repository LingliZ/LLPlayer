//
//  GHEmojiCollectionView.h
//  GHEmojiKeyboard
//
//  Created by Gaojin Hsu on 4/25/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EmojiCollectionViewBlock) (UIImage *emojiImage, NSString *emojiText);

@interface GHEmojiCollectionView : UIView

- (id)initWithFrame:(CGRect)frame emijiPlistFileName:(NSString*)plistFileName inBundle:(NSBundle*)bundle;

- (void)setEmojiCollectionViewBlock:(EmojiCollectionViewBlock)block;

@end
