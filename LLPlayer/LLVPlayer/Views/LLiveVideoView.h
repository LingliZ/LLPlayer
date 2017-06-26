//
//  LLiveVideoView.h
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVBaseView.h"


@class LLiveParam;
//直播页面
@interface LLiveVideoView : LLVBaseView

/* 直播参数 */
@property (nonatomic, strong) LLiveParam *liveParam;

@end
