//
//  LLiveToolView.h
//  xdfapp
//
//  Created by tony on 2017/6/12.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FullScreenBlock)(BOOL);
typedef void(^SwitchMediaBlock)(BOOL);

//直播的工具视图：观看人数、音视频切换、放大缩小
@interface LLiveToolView : UIImageView

+ (instancetype)lLiveToolView;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) NSString *onlineCountTitle;

@property (nonatomic, assign) NSInteger onlineCount;//观看人数

@property (nonatomic, strong) FullScreenBlock fullScreenBlock;
@property (nonatomic, strong) SwitchMediaBlock switchMediaBlock;

@end
