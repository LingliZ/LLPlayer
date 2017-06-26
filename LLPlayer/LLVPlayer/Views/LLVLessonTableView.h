//
//  LLVLessonTableView.h
//  xdfapp
//
//  Created by tony on 2017/6/20.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LLVLessonCellSelectedBlcok)(NSDictionary *);

//课节列表
@interface LLVLessonTableView : UIView

@property (nonatomic, strong) NSArray *data;

/* 点击单元格回调 */
@property (nonatomic, strong) LLVLessonCellSelectedBlcok lessonCellSelectedBlcok;

@end
