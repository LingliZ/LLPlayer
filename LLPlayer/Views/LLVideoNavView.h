//
//  LLVideoNavView.h
//  xdfapp
//
//  Created by tony on 2017/6/9.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

//导航视图
@interface LLVideoNavView : UIView

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

@end
