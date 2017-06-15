//
//  LiveVideoView.h
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLBaseVideoView.h"

typedef void(^FullScreenBlock)(BOOL);

@class LLiveParam;
//直播页面
@interface LLiveVideoView : LLBaseVideoView

/* 直播参数 */
@property (nonatomic, strong) LLiveParam *liveParam;

@property (nonatomic, strong) FullScreenBlock fullScreenBlock;

@end
