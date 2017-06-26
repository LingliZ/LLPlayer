//
//  NSObject+LLVProperty.m
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "NSObject+LLVProperty.h"
#import "LLVideoHeader.h"

@implementation NSObject (LLVProperty)

-(CGFloat)deviceScale
{
    CGFloat scale = 1.0;
    if (IS_IPHONE_6P_LL){
        scale = 1.15;
    }else if(IS_IPHONE_6_OR_LESS_LL)
    {
        scale = 0.85;
    }
    return scale;
}
@end
