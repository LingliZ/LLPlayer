//
//  PublicTool.m
//  xdfapp
//
//  Created by tony on 2017/6/13.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#define CELLHeihgt 56

#import <PlayerSDK/PlayerSDK.h>
#import "LLPublicTool.h"

@interface LLPublicTool() {
    
}

@end
@implementation LLPublicTool
static UIScrollView *BGscroll;
//网络弹出框的背景
static UIView *view;
static UIButton *currentBtn;
static NSMutableArray *titleArr;

//获取最终显示的title
+ (NSString *)getFinalTitleWithTitle:(NSString *)title andSort:(LLTitleSort)sort{
    //    标题
    NSString *suffix = @"";
    NSString *current = title;
    NSInteger length = [self textLength:current];
    
    NSInteger purposLength;
    if (sort == LLTitleSort_liveTitle) {
        purposLength = 20;
    }else {
        purposLength = 24;
    }

    if (length<=purposLength) {
        
    }else {
        while (length >purposLength-2) {
            current = [current substringToIndex:current.length-1];
            length = [self textLength:current];
            
            suffix = @"...";
        }
    }
   
    NSString *showTitle = [NSString stringWithFormat:@"%@%@",current,suffix];

    return showTitle;
}

//获取字符串的长度
+ (NSUInteger)textLength:(NSString *) text{

    NSUInteger asciiLength = 0;

    for (NSUInteger i = 0; i < text.length; i++) {
        //循环取出text里面的单个字符
        unichar uc = [text characterAtIndex: i];
        //C语言isascii()函数：判断字符是否为ASCII码字符
        asciiLength += isascii(uc) ? 1 : 2;
        
    }

    NSUInteger unicodeLength = asciiLength;

    return unicodeLength;
}

//获取资源中的图片
+ (UIImage *)imagesNamedFromCustomBundle:(NSString *)imgName

{
    
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"FastSDK.bundle/Images"];
    
    NSString *img_path = [bundlePath stringByAppendingPathComponent:imgName];
    return [UIImage imageWithContentsOfFile:img_path];
    
}

//⚠️获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

+ (UIImage*)getImageByRetina:(NSString*)imageName
{
    
    float nativeWidth=  MIN([[UIScreen mainScreen] nativeBounds].size.width,[[UIScreen mainScreen] nativeBounds].size.height);
    float screenWidth=   MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    float currentRatio=nativeWidth/screenWidth;
    if (currentRatio<2) {
        return   [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[imageName stringByAppendingString:@"@2x"]]];
    }else{
        return    [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName]];
    }
    return    [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName]];
}

@end
