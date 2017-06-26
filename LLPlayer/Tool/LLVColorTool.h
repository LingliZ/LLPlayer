//
//  LLVColorTool.h
//  xdfapp
//
//  Created by tony on 2017/6/13.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LLVColorTool : NSObject

/**
 十六进制颜色数值转为UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)string;

@end
