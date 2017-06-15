//
//  LLBaseVideoView.h
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PlayerSDK/PlayerSDK.h>
#import "LLVideoNavView.h"

//视频基类
@interface LLBaseVideoView : UIView

/* 播放器的高度 */
@property (nonatomic, assign) CGFloat playerHeight;
/* 文档的高度 */
@property (nonatomic, assign) CGFloat docHeight;

/* 选项卡（分割成段）的属性 */
@property (nonatomic, strong) UIFont *segTitleFont;
@property (nonatomic, strong) UIColor *segTitleColor;
@property (nonatomic, strong) UIColor *segHighlightTitleColor;
@property (nonatomic, strong) UIColor *segIndicatorColor;
@property (nonatomic, strong) UIColor *segLineColor;
@property (nonatomic, strong) NSArray *segmentItems;
@property (nonatomic, strong) UIColor *segBackColor;

@property (nonatomic, strong) NSString *audioPlayHolderImage;
/* 选项卡高度 */
@property (nonatomic, assign) CGFloat segHeight;

/* 导航栏的高度 */
@property (nonatomic, assign) CGFloat navHeight;
/* 导航栏 */
@property (nonatomic, strong) LLVideoNavView *navView;

- (void)fullViedoScreen:(BOOL)flag;

- (void)loadView;

@end
