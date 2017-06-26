//
//  LLVideoToolBar.m
//  xdfapp
//
//  Created by tony on 2017/6/23.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVideoToolBar.h"
#import "LLVColorTool.h"

@implementation LLVideoToolBar

+ (instancetype)lLVideoToolBar
{
    return [[self alloc] init];
}

- (void)loadMenuArr:(NSArray *)menus
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat itemWidth = self.bounds.size.width/menus.count;
    CGFloat itemHeight = self.bounds.size.height;
    
    UIView *previousView = nil;
    for(NSDictionary *menu in menus){
        
        //工具子项
        UIView *toolView = [[UIView alloc] init];
        toolView.backgroundColor = [UIColor clearColor];
        
        NSString *icon = [menu objectForKey:@"icon"];
        NSString *title = [menu objectForKey:@"title"];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
        iconImageView.contentMode = UIViewContentModeCenter;
        [toolView addSubview:iconImageView];
        [iconImageView sizeToFit];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = title;
        titleLabel.textColor = self.titleColor;
        titleLabel.font = self.titleFont;
        [toolView addSubview:titleLabel];
        [titleLabel sizeToFit];
        
        CGFloat xMargin = (itemWidth - iconImageView.image.size.width - titleLabel.bounds.size.width - (iconImageView.image.size.width?6.0:0))/2.0;
        
        iconImageView.frame = (CGRect){{xMargin, 0}, {iconImageView.image.size.width, itemHeight}};
        
        titleLabel.frame = (CGRect){{CGRectGetMaxX(iconImageView.frame) + (iconImageView.image.size.width?6.0:0)},{titleLabel.bounds.size.width, itemHeight}};
        
        if(menu != menus.lastObject){
            UIView *line = [[UIView alloc] initWithFrame:(CGRect){{itemWidth - 0.5, (itemHeight - 25.0)/2.0},{0.5, 25.0}}];
            line.backgroundColor = self.lineColor;
            [toolView addSubview:line];
        }
        
        toolView.frame = (CGRect){{CGRectGetMaxX(previousView.frame), 0}, {itemWidth, itemHeight}};
        [self addSubview:toolView];
        previousView = toolView;
    }
    
    UIView *lay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    lay.backgroundColor = self.lineColor;
    [self addSubview:lay];
}

#pragma mark - getter method
- (UIColor *)titleColor
{
    if(!_titleColor){
        _titleColor = [LLVColorTool colorWithHexString:@"#222222"];
    }
    return _titleColor;
}

- (UIFont *)titleFont
{
    if(!_titleFont){
        _titleFont = [UIFont systemFontOfSize:12.0];
    }
    return _titleFont;
}

- (UIColor *)lineColor
{
    if(!_lineColor){
        _lineColor = [LLVColorTool colorWithHexString:@"#e6e6e6"];
    }
    return _lineColor;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
