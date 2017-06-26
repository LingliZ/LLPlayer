//
//  LLVBaseView.h
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PlayerSDK/PlayerSDK.h>
#import "LLVideoNavView.h"
#import "LLVSegmentView.h"
#import "LLVLoadingView.h"
#import "LLVideoToolBar.h"
#import "LLVFunctionItem.h"

#import "LLVColorTool.h"
#import "LLVPublicTool.h"
#import "UIView+LLVExtension.h"

typedef void(^LLVNavLeftBtnClick)(id);//导航栏左边按钮block
typedef void(^LLVNavRightBtnClick)(id);//导航栏右边按钮block
typedef void(^LLVLoadLeftBtnClick)(id);//等待框左边按钮block

//视频基类
@interface LLVBaseView : UIView

/* 播放器的高度 */
@property (nonatomic, assign) CGFloat playerHeight;
/* 文档的高度 */
@property (nonatomic, assign) CGFloat docHeight;


@property (nonatomic, strong) NSArray *segmentItems;
@property (nonatomic, strong) NSArray *toolBarItems;

/* 选项卡（分割成段）的属性 */
@property (nonatomic, strong) UIFont *segTitleFont;
@property (nonatomic, strong) UIColor *segTitleColor;
@property (nonatomic, strong) UIColor *segHighlightTitleColor;
@property (nonatomic, strong) UIColor *segIndicatorColor;
@property (nonatomic, strong) UIColor *segBackColor;
@property (nonatomic, strong) UIColor *segLineColor;

/** 底部工具栏的属性*/
@property (nonatomic, strong) UIFont *toolBarTitleFont;
@property (nonatomic, strong) UIColor *toolBarTitleColor;
@property (nonatomic, strong) UIColor *toolBarBackColor;
@property (nonatomic, strong) UIColor *toolBarLineColor;

/* 选项卡高度 */
@property (nonatomic, assign) CGFloat segHeight;
/* 导航栏的高度 */
@property (nonatomic, assign) CGFloat navHeight;
/** 底部工具栏的高度*/
@property (nonatomic, assign) CGFloat toolBarHeight;

@property (nonatomic, strong) NSString *audioPlayHolderImage;

//渲染视图
- (void)loadView;

/* 导航栏 */
@property (nonatomic, strong) LLVideoNavView *navView;
@property (nonatomic, strong) LLVNavLeftBtnClick navLeftBtnClick;
@property (nonatomic, strong) LLVNavRightBtnClick navRightBtnClick;
/** 加载框 */
@property (nonatomic, strong) LLVLoadingView *loadingView;
@property (nonatomic, strong) LLVLoadLeftBtnClick loadLeftBtnClick;
/** 选项卡 */
@property (nonatomic, strong) LLVSegmentView *segmentView;
/** 底部工具栏*/
@property (nonatomic, strong) LLVideoToolBar *toolBarView;


@property (nonatomic, assign)  BOOL hasOrientation;//是否旋转屏

//处理旋转屏
- (void)fullViedoScreenFrom:(UIInterfaceOrientation)from to:(UIInterfaceOrientation)to;

@end
