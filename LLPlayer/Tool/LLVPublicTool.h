//
//  PublicTool.h
//  xdfapp
//
//  Created by tony on 2017/6/13.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

typedef NS_ENUM(NSInteger, LLTitleSort) {
    LLTitleSort_liveTitle,//直播标题
    LLTitleSort_nickNameTitle,//昵称
};

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LLVPublicTool : NSObject

/**
 获取最终显示的标题或昵称

 @param title 内容
 @param sort 是标题还是昵称
 @return 最终显示的内容
 */
+ (NSString *)getFinalTitleWithTitle:(NSString *)title andSort:(LLTitleSort)sort;

//获取资源中的图片
+ (UIImage *)imagesNamedFromCustomBundle:(NSString *)imgName;

/**
 获取当前显示的控制器 
 */
+ (UIViewController *)getCurrentVC;

+(UIImage*)getImageByRetina:(NSString*)imageName;

+ (NSString *)formatVProgressTime:(int)msec;

+ (NSString *)changeCreatTimeWithLong:(long long)creatTime  Formatter:(NSString *)formatter;

+ (NSString *)formatDateReadable:(NSString *)dateStr;
@end
