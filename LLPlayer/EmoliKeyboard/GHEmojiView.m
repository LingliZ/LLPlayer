//
//  GHEmojiView.m
//  GHEmojiKeyboard
//
//  Created by Gaojin Hsu on 4/25/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import "GHEmojiView.h"

@interface GHEmojiView ()

@property (strong, nonatomic) EmojiBlock block;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation GHEmojiView

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
