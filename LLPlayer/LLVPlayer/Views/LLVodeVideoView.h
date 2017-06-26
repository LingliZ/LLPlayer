//
//  LLVodeVideoView.h
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVBaseView.h"
@class LLVodParam;

//点播页面
@interface LLVodeVideoView : LLVBaseView

/* 点播参数 */
@property (nonatomic, strong) LLVodParam *vodParam;

@property (nonatomic, strong) downItem *item;
@property (nonatomic, assign) BOOL isLivePlay;

@end
