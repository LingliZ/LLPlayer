//
//  LLSegment.h
//  xdfapp
//
//  Created by tony on 2017/6/9.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    FunctionType_doc,//文档
    FunctionType_chat,//直播聊天
    FunctionType_lesson,//课节
    FunctionType_joinGroup,//加入群组
    FunctionType_courseConsult,//课程咨询
    FunctionType_crashHelp//卡顿求助
}LLVFunctionType;

//功能
@interface LLVFunctionItem : NSObject
@property (nonatomic, assign) LLVFunctionType type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *icon;
@end
