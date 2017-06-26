//
//  LLVLessonTableView.m
//  xdfapp
//
//  Created by tony on 2017/6/20.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVLessonTableView.h"
#import "LLVLessionCell.h"
#import "LLVPublicTool.h"
/* cell的重用标识 */
static NSString * const LLVLessionCellId = @"LLVLessionCellId";

@interface LLVLessonTableView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation LLVLessonTableView


- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    //列表
    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    // 注册cell
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([LLVLessionCell class]) bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:LLVLessionCellId];
    [self addSubview:_tableView];
}

- (void)setData:(NSArray *)data
{
    if(_data != data){
        _data = data;
        [self.tableView reloadData];
    }
}

#pragma mark - 代理方法
#pragma mark - 数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 根据数据量显示或者隐藏footer
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LLVLessionCell *cell = [tableView dequeueReusableCellWithIdentifier:LLVLessionCellId];
    NSDictionary *info = [self.data objectAtIndex:indexPath.row];
    NSString *num = [NSString stringWithFormat:@"%ld",(indexPath.row + 1)];
    NSString *title = [info objectForKey:@"title"];
    NSString *timestamp = [LLVPublicTool formatVProgressTime:[[info objectForKey:@"timestamp"] intValue]];
    if(info == self.data.lastObject){
        NSString *duration = [LLVPublicTool formatVProgressTime:[[info objectForKey:@"duration"] intValue]];
        NSDictionary *dataInfo = @{@"num":num, @"title":[NSString stringWithFormat:@"%@  %@-%@", title,timestamp, duration]};
        cell.dataInfo = dataInfo;
    }else{
        NSString *nextTimestamp = [LLVPublicTool formatVProgressTime:[[[self.data objectAtIndex:indexPath.row + 1] objectForKey:@"timestamp"] intValue]];
        NSDictionary *dataInfo = @{@"num":num, @"title":[NSString stringWithFormat:@"%@  %@-%@", title, timestamp, nextTimestamp]};
        cell.dataInfo = dataInfo;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row < self.data.count){
        if(_lessonCellSelectedBlcok){
            _lessonCellSelectedBlcok(_data[indexPath.row]);
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
