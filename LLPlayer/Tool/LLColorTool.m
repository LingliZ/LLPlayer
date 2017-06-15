//
//  LLColorTool.m
//  xdfapp
//
//  Created by tony on 2017/6/13.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLColorTool.h"

@implementation LLColorTool
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    if ([stringToConvert hasPrefix:@"#"]){
        stringToConvert = [stringToConvert substringFromIndex:1];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    
    unsigned hexNum;
    
    if (![scanner scanHexInt:&hexNum])
    {
        return nil;
    }
    return [self colorWithRGBHex:hexNum];
    
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
    int r = (hex >> 16) & 0xFF;
    
    int g = (hex >> 8) & 0xFF;
    
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
            
                           green:g / 255.0f
            
                            blue:b / 255.0f
            
                           alpha:1.0f];
}

@end
