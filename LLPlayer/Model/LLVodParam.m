//
//  LLVodParam.m
//  xdfapp
//
//  Created by tony on 2017/6/15.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVodParam.h"
#import <objc/runtime.h>
@implementation LLVodParam

- (VodParam *)vodParam
{
    VodParam *vodParam = [[VodParam alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];//属性名称
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        //Class class = NSClassFromString([propertyName capitalizedString]);
        //SEL setSel = [self creatSetterWithPropertyName:propertyName];
        [vodParam setValue:propertyValue forKey:propertyName];
    }
    return vodParam;
}

@end
