//
//  LLVSegmentView.m
//  xdfapp
//
//  Created by tony on 2017/6/9.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVSegmentView.h"
#import "LLVColorTool.h"

@interface LLVSegmentView()
@property (nonatomic, strong) UIButton * lastSelectedBtn;
@property (nonatomic, strong) UIImageView * currentLine;
@property (nonatomic, strong) NSMutableArray *butArr;
@end

@implementation LLVSegmentView
{
    SEGMENT_TYPE seleType;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.aWidth = frame.size.width;
        self.butArr = [NSMutableArray new];
    }
    return self;
}

- (void)addSelectedBlock:(void(^)(LLVSegmentView *view,NSInteger selectedIndex,NSInteger lastSelectedIndex)) block
{
    self.selectedBlock = block;
}

- (void)loadMenuArr:(NSArray *)menuNames type:(SEGMENT_TYPE)type
{
    seleType = type;
    
    switch (seleType) {
        case SEGMENT_TYPE_SEGMENT:
        {
            float width = self.aWidth / [menuNames count];
            float height = CGRectGetHeight(self.frame);
            
            for (int i = 0; i < [menuNames count]; i ++) {
                NSString * name = [menuNames objectAtIndex:i];
                UIButton * menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                float offsetX = width * i;
                menuBtn.frame = CGRectMake(offsetX,0, width, height);
                menuBtn.tag = 1000 + i;
                [menuBtn addTarget:self action:@selector(menuBtnPressed:) forControlEvents:UIControlEventTouchDown];
                [menuBtn setTitleColor:self.titleColor forState:UIControlStateNormal];
                [menuBtn setTitle:name forState:UIControlStateNormal];
                menuBtn.titleLabel.font = self.titleFont;
                menuBtn.backgroundColor = [UIColor clearColor];
                [self addSubview:menuBtn];
                
                [self.butArr addObject:menuBtn];

                if (i == 0) {
                    [menuBtn setTitleColor:self.highlightTitleColor forState:UIControlStateNormal];
                    self.lastSelectedBtn = menuBtn;
                }
            }
            
            self.currentLine = [[UIImageView alloc] initWithFrame:CGRectZero];
            self.currentLine.backgroundColor = [UIColor clearColor];
            [self addSubview:self.currentLine];
            
            self.currentLine.frame = CGRectMake(CGRectGetMinX(self.lastSelectedBtn.frame), CGRectGetHeight(self.lastSelectedBtn.frame) - 10, CGRectGetWidth(self.lastSelectedBtn.frame), 10);

            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake((self.currentLine.bounds.size.width - 25)/2, self.currentLine.bounds.size.height-2, 25, 2)];
            imageV.backgroundColor = self.indicatorColor;
            [self.currentLine addSubview:imageV];
        }
            break;
            
        default:
            break;
    }
    
    UIView *lay = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    lay.backgroundColor = self.lineColor;
    [self addSubview:lay];
}

- (void)menuBtnPressed:(UIButton *)sender
{
    switch (seleType) {
        case SEGMENT_TYPE_SEGMENT:
        {
            NSInteger index = sender.tag - 1000;
            NSInteger lastIndex = _lastSelectedBtn.tag - 1000;
            
            [UIView animateWithDuration:0.3f animations:^{
                self.currentLine.frame = CGRectMake(CGRectGetMinX(sender.frame), CGRectGetMinY(self.currentLine.frame), self.currentLine.bounds.size.width, self.currentLine.bounds.size.height);
            }];
            
            [self.lastSelectedBtn setTitleColor:self.titleColor forState:UIControlStateNormal];
            
            [sender setTitleColor:self.highlightTitleColor forState:UIControlStateNormal];
            self.lastSelectedBtn = sender;
            
            if (self.selectedBlock) {
                self.selectedBlock(self,index,lastIndex);
            }
            
        }
            break;
        default:
            break;
    }
}


- (void)setSeleIndex:(NSInteger)aIndex
{
    if ([self viewWithTag:aIndex+1000]) {
        UIButton *but = [self viewWithTag:aIndex+1000];
        [self setSeleBut:but];
    }
}

- (void)setSeleBut:(UIButton *)sender
{
    switch (seleType) {
        case SEGMENT_TYPE_SEGMENT:
        {
            self.currentLine.frame = CGRectMake(CGRectGetMinX(sender.frame), CGRectGetMinY(self.currentLine.frame), self.currentLine.bounds.size.width, self.currentLine.bounds.size.height);
            [self.lastSelectedBtn setTitleColor:self.titleColor forState:UIControlStateNormal];
            [sender setTitleColor:self.highlightTitleColor forState:UIControlStateNormal];
            self.lastSelectedBtn = sender;
        }
            break;
        default:
            break;
    }
}

- (void)setButTiele:(NSString *)aTiele forIndex:(NSInteger)aIndex;
{
    if ([self viewWithTag:aIndex+1000]) {
        UIButton *but = [self viewWithTag:aIndex+1000];
        [but setTitle:aTiele forState:UIControlStateNormal];
    }
}

#pragma mark - getter method
- (UIColor *)titleColor
{
    if(!_titleColor){
        _titleColor = [LLVColorTool colorWithHexString:@"#222222"];
    }
    return _titleColor;
}

- (UIColor *)highlightTitleColor
{
    if(!_highlightTitleColor){
        _highlightTitleColor = [LLVColorTool colorWithHexString:@"#00c498"];
    }
    return _highlightTitleColor;
}

- (UIColor *)indicatorColor
{
    if(!_indicatorColor){
        _indicatorColor = self.highlightTitleColor;
    }
    return _indicatorColor;
}

- (UIColor *)lineColor
{
    if(!_lineColor){
        _lineColor = [LLVColorTool colorWithHexString:@"#e6e6e6"];
    }
    return _lineColor;
}

- (UIFont *)titleFont
{
    if(!_titleFont){
        _titleFont = [UIFont systemFontOfSize:15.0];
    }
    return _titleFont;
}
@end
