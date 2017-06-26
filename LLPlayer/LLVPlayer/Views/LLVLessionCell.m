//
//  LLVLessionCell.m
//  xdfapp
//
//  Created by tony on 2017/6/20.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVLessionCell.h"

@interface LLVLessionCell()
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LLVLessionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //设置圆角
    self.numLabel.layer.cornerRadius = self.numLabel.bounds.size.width/2.0;
    self.numLabel.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setDataInfo:(NSDictionary *)dataInfo
{
    if(_dataInfo != dataInfo){
        _dataInfo = dataInfo;
        self.numLabel.text = [_dataInfo objectForKey:@"num"];
        self.titleLabel.text = [_dataInfo objectForKey:@"title"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
