//
//  LLVodeToolView.h
//  xdfapp
//
//  Created by tony on 2017/6/12.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FullScreenBlock)(BOOL);
typedef void(^PlayVideoBlock)(BOOL);
typedef void(^SliderSeekBlock)(CGFloat);

//点播的工具视图：进度条、放大缩小
@interface LLVodeToolView : UIImageView

+ (instancetype)lLVodeToolView;

@property (nonatomic, strong) NSString *vodTotalTime;//点播的总时间
@property (nonatomic, strong) FullScreenBlock fullScreenBlock;
@property (nonatomic, strong) PlayVideoBlock playVideoBlock;
@property (nonatomic, strong) SliderSeekBlock sliderSeekBlock;
@property (nonatomic, strong) NSString *timeTitleStr;

@property (nonatomic, strong) UIButton *playBtn;//播放按钮
@property(nonatomic) float miniProgressValue;
@property(nonatomic) float maxProgressValue;
@property (nonatomic, assign) BOOL isProgressDragging;

- (void)setProgressValue:(float)value animated:(BOOL)animated;

@end
