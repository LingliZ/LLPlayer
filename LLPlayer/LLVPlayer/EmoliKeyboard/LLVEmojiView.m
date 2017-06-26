//
//  LLVEmojiView.m
//  LLVEmojiKeyboard
//
//  Created by tony on 2017/6/19.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVEmojiView.h"

@interface LLVEmojiView ()

@property (strong, nonatomic) EmojiBlock block;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation LLVEmojiView

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = 24;
    frame.size.width = 24;
    
    self.backgroundColor = [UIColor clearColor];
    self = [super initWithFrame:frame];
    
    if (self) {
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
        [self addSubview: self.imageView];
    }
    
    return self;
}

- (void)setEmojiBlock:(EmojiBlock)block
{
    self.block = block;
}

- (void)setEmojiImage:(UIImage *)emojiImage EmojiText:(NSString *)emojiText
{
    [self.imageView setImage:emojiImage];
    
    self.emojiImage = emojiImage;
    
    self.emojiText = emojiText;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, point)) {
        self.block(self.emojiImage, self.emojiText);
    }
}

@end
