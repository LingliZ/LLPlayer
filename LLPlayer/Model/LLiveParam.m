//
//  LLiveParam.m
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLiveParam.h"
#import <objc/runtime.h>
@implementation LLiveParam

- (instancetype)init
{
    if(self = [super init]){
        self.needsValidateCustomUserID = YES;
    }
    return self;
}

- (GSPJoinParam *)gspJoinParam
{
    GSPJoinParam *joinParam = [[GSPJoinParam alloc] init];
    
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
        [joinParam setValue:propertyValue forKey:propertyName];
    }
    return joinParam;
}

#pragma mark -- 通过字符串来创建该字符串的Setter方法，并返回
- (SEL)creatSetterWithPropertyName: (NSString *) propertyName{
    
    //1.首字母大写
    propertyName = propertyName.capitalizedString;
    
    //2.拼接上set关键字
    propertyName = [NSString stringWithFormat:@"set%@:", propertyName];
    
    //3.返回set方法
    return NSSelectorFromString(propertyName);
}
@end
