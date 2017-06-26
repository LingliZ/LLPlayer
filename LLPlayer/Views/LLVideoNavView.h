//
//  LLVideoNavView.h
//  xdfapp
//
//  Created by tony on 2017/6/9.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LLVNavLeftBtnBlock)(UIButton *);
typedef void(^LLVNavRightBtnBlock)(UIButton *);

//导航视图
@interface LLVideoNavView : UIImageView

/* 导航栏左边按钮 */
@property (nonatomic, strong) NSArray *leftButtonItems;
/* 导航栏右边边按钮 */
@property (nonatomic, strong) NSArray *rightButtonItems;
/* 导航栏的标题 */
@property (nonatomic, strong) NSString *title;
/* 标题颜色 */
@property (nonatomic, strong) UIColor *titleColor;
/* 标题字体大小 */
@property (nonatomic, strong) UIFont *titleFont;

//最左边的按钮
@property (nonatomic, strong) UIButton *leftBtn;
//最右边的按钮
@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) LLVNavLeftBtnBlock navLeftBtnBlock;

@property (nonatomic, strong) LLVNavRightBtnBlock navRightBtnBlock;

@end
