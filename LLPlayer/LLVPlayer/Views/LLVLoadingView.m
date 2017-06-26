//
//  LLVLoadingView.m
//  xdfapp
//
//  Created by tony on 2017/6/21.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVLoadingView.h"
#import "NSObject+LLVProperty.h"
#import "UIView+LLVExtension.h"
#import "LLVColorTool.h"

@interface LLVLoadingView()
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIButton *btn;

@property (nonatomic, assign) double angle;
@property (nonatomic, assign) BOOL isEndAnimation;

@property (nonatomic, assign) LLVLoadingState state;
@end

@implementation LLVLoadingView

@synthesize loadIcon = _loadIcon;
@synthesize indicatorIcon = _indicatorIcon;
@synthesize titleColor = _titleColor;
@synthesize titleFont = _titleFont;
@synthesize errorFont = _errorFont;
@synthesize errorColor = _errorColor;
@synthesize loadTitle = _loadTitle;
@synthesize errorTitle = _errorTitle;
@synthesize btnTitle = _btnTitle;
@synthesize btnBgColor = _btnBgColor;
@synthesize btnTitleColor = _btnTitleColor;
@synthesize btnTitleFont = _btnTitleFont;

- (void)dealloc
{
    
}

+ (instancetype)LLVLoadingView
{
    return [[self alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_iconImageView];
    
    _indicatorImageView = [[UIImageView alloc] init];
    _indicatorImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_indicatorImageView];
    
    _loadingLabel = [[UILabel alloc] init];
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_loadingLabel];
    
    _errorLabel = [[UILabel alloc] init];
    _errorLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_errorLabel];
    
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btn];
    
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftBtn setImage:[UIImage imageNamed:@"ll_loading_return"] forState:UIControlStateNormal];
    _leftBtn.frame = (CGRect){{0, 20.0},{30 + _leftBtn.currentImage.size.width, 44.0}};
    [_leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftBtn];
}

- (void)setLoadIcon:(NSString *)loadIcon
{
    _loadIcon = loadIcon;
    _iconImageView.image = [UIImage imageNamed:_loadIcon];
}

- (void)setIndicatorIcon:(NSString *)indicatorIcon
{
    _indicatorIcon = indicatorIcon;
    _indicatorImageView.image = [UIImage imageNamed:_indicatorIcon];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    _loadingLabel.textColor = _titleColor;
}

- (void)setErrorColor:(UIColor *)errorColor
{
    _errorColor = errorColor;
    _errorLabel.textColor = _errorColor;
}

- (void)setBtnBgColor:(UIColor *)btnBgColor
{
    _btnBgColor = btnBgColor;
    [_btn setBackgroundColor:_btnBgColor];
}

- (void)setBtnTitleColor:(UIColor *)btnTitleColor
{
    _btnTitleColor = btnTitleColor;
    [_btn setTitleColor:_btnTitleColor forState:UIControlStateNormal];
    [_btn setTitleColor:_btnTitleColor forState:UIControlStateHighlighted];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    _loadingLabel.font = _titleFont;
}

- (void)setErrorFont:(UIFont *)errorFont
{
    _errorFont = errorFont;
    _errorLabel.font = _errorFont;
}

- (void)setBtnTitleFont:(UIFont *)btnTitleFont
{
    _btnTitleFont = btnTitleFont;
    _btn.titleLabel.font = _btnTitleFont;
}

- (void)setLoadTitle:(NSString *)loadTitle
{
    _loadTitle = loadTitle;
    _loadingLabel.text = _loadTitle;
}

- (void)setErrorTitle:(NSString *)errorTitle
{
    _errorTitle = errorTitle;
    _errorLabel.text = _errorTitle;
}

- (void)setBtnTitle:(NSString *)btnTitle
{
    _btnTitle = btnTitle;
    [_btn setTitle:_btnTitle forState:UIControlStateNormal];
}


- (void)loadLoadingView
{
    if(_indicatorImageView.frame.size.width == 0 || _iconImageView.frame.size.width == 0){
        _iconImageView.frame = (CGRect){{0, self.loadIconMarginY},{self.bounds.size.width,_iconImageView.image.size.height}};
        
        _indicatorImageView.frame = (CGRect){{0, CGRectGetMaxY(_iconImageView.frame) + 56.0}, {self.bounds.size.width, _indicatorImageView.image.size.height}};
        
        [_loadingLabel sizeToFit];
        _loadingLabel.frame = (CGRect){{0,CGRectGetMaxY(_indicatorImageView.frame) + 22.0}, {self.bounds.size.width, _loadingLabel.bounds.size.height}};
        _loadingLabel.font = self.titleFont;
        _loadingLabel.textColor = self.titleColor;
    }
    _loadingLabel.hidden = NO;
    _indicatorImageView.hidden = NO;
    _errorLabel.hidden = YES;
    _btn.hidden = YES;
}

- (void)loadErrorView
{
    if(_errorLabel.frame.size.width == 0 || _btn.frame.size.width == 0){
        [_errorLabel sizeToFit];
        _errorLabel.frame = (CGRect){{0,CGRectGetMaxY(_iconImageView.frame) + 79.0}, {self.bounds.size.width, _errorLabel.bounds.size.height}};
        _errorLabel.font = self.errorFont;
        _errorLabel.textColor = self.errorColor;
        
        _btn.frame = (CGRect){{(self.bounds.size.width - self.btnWidth)/2.0, CGRectGetMaxY(_errorLabel.frame) + 59.0}, {self.btnWidth, self.btnHeight}};
        _btn.layer.cornerRadius = self.btnHeight/2.0;
        [_btn setBackgroundColor:self.btnBgColor];
        [_btn setTitleColor:self.btnTitleColor forState:UIControlStateNormal];
        [_btn setTitleColor:self.btnTitleColor forState:UIControlStateHighlighted];
        _btn.titleLabel.font = self.btnTitleFont;
    }
    _loadingLabel.hidden = YES;
    _indicatorImageView.hidden = YES;
    _errorLabel.hidden = NO;
    _btn.hidden = NO;
}

- (void)loadWithState:(LLVLoadingState)state withTitle:(NSString *)title
{
    _state = state;
    _angle = 0.0;
    switch (state) {
        case LLVLoadingState_start:
        {
            _loadingLabel.text = title;
            [self loadLoadingView];
            CGAffineTransform endAngle = CGAffineTransformMakeRotation(0);
            _indicatorImageView.transform = endAngle;
            self.isEndAnimation = NO;
            [self startAnimation:_indicatorImageView];
        }
            break;
        case LLVLoadingState_sucess:
        {
            self.isEndAnimation = YES;
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }
            break;
        case LLVLoadingState_netFail:
        {
            self.isEndAnimation = YES;
            _errorLabel.text = title;
            [_btn setTitle:@"刷新" forState:UIControlStateNormal];
            [self loadErrorView];
        }
            break;
        case LLVLoadingState_offLine:
        {
            self.isEndAnimation = YES;
            _errorLabel.text = title;
            [_btn setTitle:@"刷新" forState:UIControlStateNormal];
            [self loadErrorView];
        }
            break;
        case LLVLoadingState_otherError:
        {
            self.isEndAnimation = YES;
            _errorLabel.text = title;
            [_btn setTitle:@"刷新" forState:UIControlStateNormal];
            [self loadErrorView];
        }
            break;
        default:
        {
            self.isEndAnimation = YES;
            self.isEndAnimation = YES;
            _errorLabel.text = title;
            [_btn setTitle:@"刷新" forState:UIControlStateNormal];
            [self loadErrorView];
        }
            break;
    }
}

- (void)leftBtnClick:(UIButton *)sender
{
    if(_loadLeftBtnClick){
        _loadLeftBtnClick(sender);
    }else{
        [[self viewController].navigationController popViewControllerAnimated:YES];
    }
}

- (void)btnClick:(UIButton *)sender
{
    __weak __typeof(&*self) weakSelf = self;
    if(_loadBtnClick){
        _loadBtnClick(weakSelf.state);
    }
}

- (void)startAnimation:(UIImageView *)imageView
{
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(self.angle * (M_PI / 180.0f));
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        imageView.transform = endAngle;
    } completion:^(BOOL finished) {
        self.angle += 10;
        if(!self.isEndAnimation){
            [self startAnimation:imageView];
        }
    }];
}

- (CGFloat)btnWidth
{
    if(_btnWidth == 0){
        _btnWidth = 100*self.deviceScale;
    }
    return _btnWidth;
}

- (CGFloat)btnHeight
{
    if(_btnHeight == 0){
        _btnHeight = 33.0*self.deviceScale;
    }
    return _btnHeight;
}

- (UIColor *)btnBgColor
{
    if(!_btnBgColor){
        _btnBgColor = [LLVColorTool colorWithHexString:@"00c498"];
    }
    return _btnBgColor;
}

- (UIColor *)btnTitleColor
{
    if(!_btnTitleColor){
        _btnTitleColor = [LLVColorTool colorWithHexString:@"ffffff"];
    }
    return _btnTitleColor;
}

- (UIColor *)titleColor
{
    if(!_titleColor){
        _titleColor = [LLVColorTool colorWithHexString:@"#999999"];
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

- (UIColor *)errorColor
{
    if(!_errorColor){
        _errorColor = [LLVColorTool colorWithHexString:@"#222222"];
    }
    return _errorColor;
}

- (UIFont *)errorFont
{
    if(!_titleFont){
        _titleFont = [UIFont systemFontOfSize:14.0];
    }
    return _titleFont;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
