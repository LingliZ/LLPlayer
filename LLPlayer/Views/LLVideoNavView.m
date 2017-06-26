//
//  LLVideoNavView.m
//  xdfapp
//
//  Created by tony on 2017/6/9.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVideoNavView.h"
#import "UIView+LLVExtension.h"

@interface LLVideoNavView()
@property (nonatomic, weak) UILabel *titleLabel;
@end


@implementation LLVideoNavView

@synthesize leftButtonItems = _leftButtonItems;
@synthesize rightButtonItems = _rightButtonItems;
@synthesize titleFont = _titleFont;
@synthesize titleColor = _titleColor;

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        self.userInteractionEnabled = YES;
        [self initDefualtData];
        [self setupSubViews];
    }
    return self;
}

- (void)initDefualtData
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"ll_viedo_nav_return_01"] forState:UIControlStateNormal];
    btn.frame = (CGRect){{0, self.navContentMarginY},{30 + btn.currentImage.size.width, self.navContentHeight}};
    [btn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _leftButtonItems = [NSArray arrayWithObject:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"ll_viedo_nav_share_01"] forState:UIControlStateNormal];
    btn.frame = (CGRect){{self.bounds.size.width - (30 + btn.currentImage.size.width), self.navContentMarginY},{30 + btn.currentImage.size.width, self.navContentHeight}};
    [btn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _rightButtonItems = [NSArray arrayWithObject:btn];
}

- (void)setupSubViews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_titleLabel removeFromSuperview];
    
    for(UIButton *btn in _leftButtonItems){
        [self addSubview:btn];
    }
    for(UIButton *btn in _rightButtonItems){
        [self addSubview:btn];
    }
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = self.titleColor;
    titleLabel.font = self.titleFont;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    //标题布局
    CGFloat leftMargin = 0;
    CGFloat rightMargin = self.bounds.size.width;
    if(_leftButtonItems.count){
        UIButton *lastBtn = _leftButtonItems.lastObject;
        leftMargin = CGRectGetMaxX(lastBtn.frame);
    }
    if(_rightButtonItems.count){
        UIButton *firstBtn = _rightButtonItems.firstObject;
        rightMargin = CGRectGetMinX(firstBtn.frame);
    }
    _titleLabel.frame = (CGRect){{leftMargin, self.navContentMarginY},{rightMargin - leftMargin, self.navContentHeight}};
}

#pragma mark - setter method
- (void)setLeftButtonItems:(NSArray *)leftButtonItems
{
    if(_leftButtonItems != leftButtonItems){
        _leftButtonItems = leftButtonItems;
    }
    [self setupSubViews];
}

- (void)setRightButtonItems:(NSArray *)rightButtonItems
{
    if(_rightButtonItems != rightButtonItems){
        _rightButtonItems = rightButtonItems;
    }
    [self setupSubViews];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = title;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    _titleLabel.font = _titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    _titleLabel.textColor = _titleColor;
}

#pragma mark - getter method
- (UIButton *)leftBtn
{
    if(_leftButtonItems.count){
        _leftBtn = [_leftButtonItems firstObject];
    }
    return _leftBtn;
}

- (UIButton *)rightBtn
{
    if(_rightButtonItems.count){
        _rightBtn = [_rightButtonItems firstObject];
    }
    return _rightBtn;
}

- (CGFloat)navContentHeight
{
    return (self.bounds.size.height - self.navContentMarginY);
}

- (CGFloat)navContentMarginY
{
    return 20.0;
}

- (UIFont *)titleFont
{
    if(!_titleFont){
        _titleFont = [UIFont systemFontOfSize:16.0];
    }
    return _titleFont;
}

- (UIColor *)titleColor
{
    if(!_titleColor){
        _titleColor = [UIColor whiteColor];
    }
    return _titleColor;
}

#pragma mark - btn method
- (void)leftBtnClick:(UIButton *)sender
{
    if(_navLeftBtnBlock){
        _navLeftBtnBlock(sender);
    }else{
        [[self viewController].navigationController popViewControllerAnimated:YES];
    }
}

- (void)rightBtnClick:(UIButton *)sender
{
    if(_navRightBtnBlock){
        _navRightBtnBlock(sender);
    }
}

#pragma mark - life cycle method
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(!_titleLabel){
        [self setupSubViews];
    }else{
        [self initDefualtData];
        [self setupSubViews];
        _titleLabel.text = _title;
    }
}
@end
