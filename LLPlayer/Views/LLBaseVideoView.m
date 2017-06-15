//
//  LLBaseVideoView.m
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLBaseVideoView.h"
#import "NSObject+LLProperty.h"
@implementation LLBaseVideoView
//播放器高度
- (CGFloat)playerHeight
{
    if(_playerHeight == 0){
        _playerHeight = 281.0*self.deviceScale;
    }
    return _playerHeight;
}

- (CGFloat)docHeight
{
    if(_docHeight == 0){
        _docHeight = 212.0*self.deviceScale;
    }
    return _docHeight;
}

- (CGFloat)segHeight
{
    if(_segHeight == 0){
        _segHeight = 40.0;
    }
    return _segHeight;
}

- (CGFloat)navHeight
{
    if(_navHeight == 0){
        _navHeight = 64.0;
    }
    return _navHeight;
}


- (NSString *)audioPlayHolderImage
{
    if(!_audioPlayHolderImage){
        _audioPlayHolderImage = @"ll_only_audio_bj";
    }
    return _audioPlayHolderImage;
}

- (UIColor *)segBackColor
{
    if(!_segBackColor){
        _segBackColor = [UIColor whiteColor];
    }
    return _segBackColor;
}

- (void)loadView
{

}

//视频全屏
- (void)fullViedoScreen:(BOOL)flag
{

}
@end
