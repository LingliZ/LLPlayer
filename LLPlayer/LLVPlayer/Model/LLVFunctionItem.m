//
//  LLSegment.m
//  xdfapp
//
//  Created by tony on 2017/6/9.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVFunctionItem.h"

@implementation LLVFunctionItem

- (NSString *)title
{
    if(!_title){
        _title = @"";
    }
    return _title;
}
@end
