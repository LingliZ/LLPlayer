//
//  UIView+LLExtension.m
//  xdfapp
//
//  Created by tony on 2017/6/9.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "UIView+LLVExtension.h"

@implementation UIView (LLExtension)

//------------事件效应者-----------
- (UIViewController *)viewController
{
    //找到控制器这个响应者
    UIResponder* nextRes = [self nextResponder];
    do{
        if([nextRes isKindOfClass:[UIViewController class]]){
            return (UIViewController*)nextRes;
        }
        nextRes = [nextRes nextResponder];
        
    }while (nextRes != nil);
    
    return [self getCurrentVC];
    return nil;
}

- (UIViewController *)getCurrentVC
{
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
