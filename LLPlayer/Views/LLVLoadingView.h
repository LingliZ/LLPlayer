//
//  LLVLoadingView.h
//  xdfapp
//
//  Created by tony on 2017/6/21.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    LLVLoadingState_start,//开始
    LLVLoadingState_sucess,//成功
    LLVLoadingState_netFail,//网络失败
    LLVLoadingState_offLine, //直播未开始
    LLVLoadingState_otherError //其他错误
}LLVLoadingState;

typedef void(^LLVLoadBtnClick)(LLVLoadingState);
typedef void(^LLVLoadLeftBtnBlock)(UIButton *);

@interface LLVLoadingView : UIView

@property (nonatomic, strong) NSString *loadIcon;
@property (nonatomic, strong) NSString *indicatorIcon;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *errorColor;
@property (nonatomic, strong) UIFont *errorFont;
@property (nonatomic, strong) UIColor *btnBgColor;
@property (nonatomic, strong) UIColor *btnTitleColor;
@property (nonatomic, strong) UIFont *btnTitleFont;

//最左边的按钮
@property (nonatomic, strong) UIButton *leftBtn;

@property (nonatomic, strong) NSString *btnTitle;
@property (nonatomic, strong) NSString *loadTitle;
@property (nonatomic, strong) NSString *errorTitle;

@property (nonatomic, assign) CGFloat  loadIconMarginY;
@property (nonatomic, assign) CGFloat  btnWidth;
@property (nonatomic, assign) CGFloat  btnHeight;

@property (nonatomic, strong) LLVLoadBtnClick loadBtnClick;
@property (nonatomic, strong) LLVLoadLeftBtnBlock loadLeftBtnClick;

- (void)loadWithState:(LLVLoadingState)state withTitle:(NSString *)title;

+ (instancetype)LLVLoadingView;

@end
