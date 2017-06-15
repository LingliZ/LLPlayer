//
//  GHEmojiCollectionView.m
//  GHEmojiKeyboard
//
//  Created by Gaojin Hsu on 4/25/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import "GHEmojiCollectionView.h"
#import "GHEmojiView.h"

#define emojiViewWidth 33

@interface GHEmojiCollectionView ()

@property (strong, nonatomic) EmojiCollectionViewBlock block;

@property (strong, nonatomic) UIImage *emojiImage;

@property (strong, nonatomic) NSString *emojiText;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSBundle *resourceBundle;

@end

@implementation GHEmojiCollectionView

- (id)initWithFrame:(CGRect)frame emijiPlistFileName:(NSString*)plistFileName inBundle:(NSBundle *)bundle;
{
    self = [super initWithFrame:frame];
    
    if (self) {
                
        NSString *path = [bundle pathForResource:plistFileName ofType:@"plist"];

        NSDictionary *emojis = [NSDictionary dictionaryWithContentsOfFile:path];
        
        if (emojis.count == 0) {
            NSLog(@"plist file not exist !");
        }
        else
        {
            [self displayEmojis: emojis inBundle:(NSBundle*)bundle];
        }
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setEmojiCollectionViewBlock:(EmojiCollectionViewBlock)block
{
    self.block = block;
}

- (void)displayEmojis:(NSDictionary *)emojis inBundle:(NSBundle*)bundle
{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];
    
    // scrollView Constraint
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *scrollViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_scrollView]-10-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_scrollView)];
    [self addConstraints:scrollViewH];
    
    NSArray *scrollViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_scrollView]-10-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_scrollView)];
    [self addConstraints:scrollViewV];
    
//    CGFloat scrollViewHeight = self.frame.size.height - 20;
    CGFloat scrollViewWidth = self.frame.size.width;
//    CGFloat width = (emojis.count/(scrollViewHeight/emojiViewWidth))*emojiViewWidth;
    CGFloat height = (emojis.count/(scrollViewWidth/emojiViewWidth))*emojiViewWidth;
    self.scrollView.contentSize = CGSizeMake(0, height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    
    // Add all emojis to EmojiCollectionView;
    
    CGFloat x = 0;
    CGFloat y = 0;
    
    NSArray *allKeys = [emojis allKeys];
    for (int i = 0; i < allKeys.count; i++) {
        
        UIImage *emojiImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:[emojis objectForKey:allKeys[i]] ofType:nil]];
        
        NSString *emojiText = allKeys[i];
        
        y = (i / (int)(scrollViewWidth / emojiViewWidth)) * emojiViewWidth;
        x = (i % (int)(scrollViewWidth / emojiViewWidth)) * emojiViewWidth;
        
        GHEmojiView *emojiView = [[GHEmojiView alloc]initWithFrame:CGRectMake(x, y, 0, 0)];
        [emojiView setEmojiImage:emojiImage EmojiText:emojiText];
        
        __weak __block GHEmojiCollectionView *copy_self = self;
        [emojiView setEmojiBlock:^(UIImage *emojiImage, NSString *emojiText){
            copy_self.block(emojiImage, emojiText);
         }];
        
        [self.scrollView addSubview:emojiView];
    }
    
    [self.scrollView setNeedsDisplay];
}

@end
