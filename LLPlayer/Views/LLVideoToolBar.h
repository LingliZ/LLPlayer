//
//  LLVideoToolBar.h
//  xdfapp
//
//  Created by tony on 2017/6/23.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

//底部工具：加入学习群、课程指南、卡顿求助
@interface LLVideoToolBar : UIView

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *lineColor;//线条的颜色


+ (instancetype)lLVideoToolBar;

- (void)loadMenuArr:(NSArray *)menus;

@end
