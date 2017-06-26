//
//  LLVLessionCell.h
//  xdfapp
//
//  Created by tony on 2017/6/20.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLVLessionCell : UITableViewCell

/* 参数 */
@property (nonatomic, strong) NSDictionary *dataInfo;

@property (weak, nonatomic) IBOutlet UIView *line;
@end
