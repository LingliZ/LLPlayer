//
//  LLiveToolView.m
//  xdfapp
//
//  Created by tony on 2017/6/12.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLiveToolView.h"

@interface LLiveToolView()
@property (nonatomic, strong) UILabel *onlineCountLabel;
@property (nonatomic, strong) UIButton *switchBtn;//音视频切换按钮
@property (nonatomic, strong) UIButton  *zoomBtn;//音视频缩放按钮
@end

@implementation LLiveToolView

+ (instancetype)lLiveToolView
{
    return [[self alloc] init];
}

- (instancetype)init
{
    if(self = [super init]){
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    //在线人数
    _onlineCountLabel = [[UILabel alloc] init];
    _onlineCountLabel.textColor = self.textColor;
    _onlineCountLabel.font = self.textFont;
    [self addSubview:_onlineCountLabel];
    
    //音视频切换按钮
    _switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_switchBtn setImage:[UIImage imageNamed:@"ll_icon_transmit"] forState:UIControlStateNormal];
    [_switchBtn setImage:[UIImage imageNamed:@"ll_icon_transmited"] forState:UIControlStateSelected];
    [_switchBtn addTarget:self action:@selector(switchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_switchBtn];
    
    //音视频缩放按钮
    _zoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_zoomBtn setImage:[UIImage imageNamed:@"ll_icon_fullscree"] forState:UIControlStateNormal];
    [_zoomBtn addTarget:self action:@selector(zoomBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_zoomBtn];
}

#pragma mark - btn method
- (void)switchBtn:(UIButton *)sender
{
    sender.selected = ! sender.isSelected;
    if(_switchMediaBlock){
        _switchMediaBlock(sender.isSelected);
    }
}

- (void)zoomBtn:(UIButton *)sender
{
    sender.selected = ! sender.isSelected;
    if(_fullScreenBlock){
        _fullScreenBlock(sender.isSelected);
    }
}

#pragma mark - setter method
- (void)setOnlineCount:(NSInteger)onlineCount
{
    _onlineCount = onlineCount;
    _onlineCountLabel.text = [NSString stringWithFormat:@"%@%ld",self.onlineCountTitle,onlineCount];
}

#pragma mark - getter method
- (UIFont *)textFont
{
    if(!_textFont){
        _textFont = [UIFont systemFontOfSize:12.0];
    }
    return _textFont;
}

- (UIColor *)textColor
{
    if(!_textColor){
        _textColor = [UIColor whiteColor];
    }
    return _textColor;
}

- (NSString *)onlineCountTitle
{
    if(!_onlineCountTitle){
        _onlineCountTitle = @"观看人数:";
    }
    return _onlineCountTitle;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize zoomBtnSize = (CGSize){_zoomBtn.currentImage.size.height + 30.0, _zoomBtn.currentImage.size.width + 30.0};
    CGSize switchBtnSize = (CGSize){_switchBtn.currentImage.size.height + 30.0, _switchBtn.currentImage.size.width + 30.0};
    _zoomBtn.frame = (CGRect){{self.bounds.size.width - zoomBtnSize.width, (self.bounds.size.height - switchBtnSize.height)/2.0}, zoomBtnSize};
    _switchBtn.frame = (CGRect){{CGRectGetMinX(_zoomBtn.frame) - switchBtnSize.width, (self.bounds.size.height - switchBtnSize.height)/2.0}, switchBtnSize};
    _onlineCountLabel.frame = (CGRect){{15.0,0}, {CGRectGetMinX(_switchBtn.frame) - 15.0, self.bounds.size.height}};
}
@end
