//
//  LLVodeToolView.m
//  xdfapp
//
//  Created by tony on 2017/6/12.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVodeToolView.h"
#import "LLVColorTool.h"
@interface LLVodeToolView()

@property (nonatomic, strong) UISlider *progress;
@property (nonatomic, strong) UIButton  *zoomBtn;//音视频缩放按钮
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation LLVodeToolView

+ (instancetype)lLVodeToolView
{
    return [[self alloc] init];
}

- (instancetype)init
{
    if(self = [super init]){
        self.userInteractionEnabled = YES;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn setImage:[UIImage imageNamed:@"ll_icon_play"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"ll_icon_pause"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(doPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playBtn];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:10.0];
    _timeLabel.textColor = [LLVColorTool colorWithHexString:@"#FFFFFF"];
    _timeLabel.text = @"00:00/00:00";
    [self addSubview:_timeLabel];
    
    _progress = [[UISlider alloc] init];
    _progress.minimumTrackTintColor = [LLVColorTool colorWithHexString:@"#00c498"];
    // 通常状态下
    [_progress setThumbImage:[UIImage imageNamed:@"ll_slider_icon_point"] forState:UIControlStateNormal];
    // 滑动状态下
    [_progress setThumbImage:[UIImage imageNamed:@"ll_slider_icon_point"] forState:UIControlStateHighlighted];
    [self addSubview:_progress];
    
    [_progress addTarget:self action:@selector(doSeek:) forControlEvents:UIControlEventTouchUpInside];
    [_progress addTarget:self action:@selector(doHold:) forControlEvents:UIControlEventTouchDown];
    
    //音视频缩放按钮
    _zoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_zoomBtn setImage:[UIImage imageNamed:@"ll_icon_fullscree"] forState:UIControlStateNormal];
    [_zoomBtn addTarget:self action:@selector(zoomBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_zoomBtn];
}

//播放或者暂停
- (void)doPlay:(UIButton *)sender
{
    _playBtn.selected = !sender.selected;
    if(_playVideoBlock){
        _playVideoBlock(!_playBtn.selected);
    }
}

- (void)doHold:(UISlider*)slider
{
    self.isProgressDragging = YES;
}

//滑动条监听方法
- (void)doSeek:(UISlider*)slider
{
    if(_sliderSeekBlock){
        _sliderSeekBlock(slider.value);
    }
}

#pragma mark - btn method
- (void)zoomBtn:(UIButton *)sender
{
    sender.selected = ! sender.isSelected;
    if(_fullScreenBlock){
        _fullScreenBlock(sender.isSelected);
    }
}

#pragma mark - setter method
- (void)setMiniProgressValue:(float)miniProgressValue
{
    _progress.minimumValue = miniProgressValue;
}

- (void)setMaxProgressValue:(float)maxProgressValue
{
    _progress.maximumValue = maxProgressValue;
}

- (void)setProgressValue:(float)value animated:(BOOL)animated
{
    [_progress setValue:value animated:animated];
}

- (void)setTimeTitleStr:(NSString *)timeTitleStr
{
    if(_timeTitleStr != timeTitleStr){
        _timeLabel.text = timeTitleStr;
        if(_timeTitleStr.length != timeTitleStr.length){
            [self layoutSubviews];
        }
        _timeTitleStr = timeTitleStr;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize zoomBtnSize = (CGSize){_zoomBtn.currentImage.size.width + 30.0, _zoomBtn.currentImage.size.height + 30.0};
    _zoomBtn.frame = (CGRect){{self.bounds.size.width - zoomBtnSize.width, (self.bounds.size.height - zoomBtnSize.height)/2.0}, zoomBtnSize};
    
    CGSize playBtnSize = (CGSize){_playBtn.currentImage.size.width + 30.0, _playBtn.currentImage.size.height + 30.0};
    _playBtn.frame = (CGRect){{0, (self.bounds.size.height - playBtnSize.height)/2.0}, playBtnSize};
    
    [_timeLabel sizeToFit];
    _timeLabel.frame = (CGRect){{CGRectGetMaxX(_playBtn.frame), 0}, {_timeLabel.bounds.size.width + 5.0, self.bounds.size.height}};
    
    CGSize progressSize = (CGSize){CGRectGetMinX(_zoomBtn.frame) - CGRectGetMaxX(_timeLabel.frame) - 5.0, self.bounds.size.height};
    _progress.frame = (CGRect){{CGRectGetMaxX(_timeLabel.frame) + 5.0, (self.bounds.size.height - progressSize.height)/2.0}, progressSize};
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
