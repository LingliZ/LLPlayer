//
//  LLSegmentView.h
//  xdfapp
//
//  Created by tony on 2017/6/9.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    SEGMENT_TYPE_SEGMENT
}SEGMENT_TYPE;

//分段选择器
@interface LLSegmentView : UIView
@property (nonatomic, assign) float aWidth;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *highlightTitleColor;
@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor *lineColor;

@property(nonatomic , copy) void(^ selectedBlock)(LLSegmentView *view,NSInteger selectedIndex,NSInteger lastSelectedIndex);

- (void)loadMenuArr:(NSArray *)menuNames type:(SEGMENT_TYPE)type;

- (void)addSelectedBlock:(void(^)(LLSegmentView *view,NSInteger selectedIndex,NSInteger lastSelectedIndex)) block;

- (void)setSeleIndex:(NSInteger)aIndex;

- (void)setButTiele:(NSString *)aTiele forIndex:(NSInteger)aIndex;

@end
