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
    SegmentItmeType_live_doc,//直播文档
    SegmentItmeType_live_chat,//直播聊天
    SegmentItmeType_vode_doc,//回播文档
    SegmentItmeType_vode_lesson,//回播课节
    SegmentItmeType_vode_chat//回播聊天
}SegmentItmeType;


@interface LLSegmentItem : NSObject
@property (nonatomic, assign) SegmentItmeType type;
@property (nonatomic, strong) NSString *title;
@end
