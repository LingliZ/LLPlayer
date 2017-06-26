//
//  LLVBaseView.m
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVBaseView.h"
#import "NSObject+LLVProperty.h"
@implementation LLVBaseView

//负责加载统一的数据
- (void)loadView
{
    __weak __typeof(&*self) weakSelf = self;
     self.navView.navLeftBtnBlock = ^(UIButton *btn){
        if(weakSelf.navLeftBtnClick){
            weakSelf.navLeftBtnClick(btn);
        }else{
            if(weakSelf.hasOrientation){
                [weakSelf fullViedoScreen];
            }else{
                [[weakSelf viewController].navigationController popViewControllerAnimated:YES];
            }
        }
    };
    self.navView.navRightBtnBlock = ^(UIButton *sender) {
        if(weakSelf.navRightBtnClick){
            
        }else{
            
        }
    };
    
    self.segmentView.backgroundColor = self.segBackColor;
    self.segmentView.titleFont = self.segTitleFont;
    self.segmentView.titleColor = self.segTitleColor;
    self.segmentView.highlightTitleColor = self.segHighlightTitleColor;
    self.segmentView.indicatorColor = self.segIndicatorColor;
    self.segmentView.lineColor = self.segLineColor;
    NSMutableArray *titles = [NSMutableArray array];
    for(LLVFunctionItem *item in self.segmentItems){
        [titles addObject:item.title];
    }
    [self.segmentView loadMenuArr:titles type:SEGMENT_TYPE_SEGMENT];
    [self.segmentView addSelectedBlock:^(LLVSegmentView *view, NSInteger selectedIndex, NSInteger lastSelectedIndex) {
        if(selectedIndex != lastSelectedIndex){
            [weakSelf doSelected:[weakSelf.segmentItems objectAtIndex:selectedIndex]];
        }
    }];
    
    self.toolBarView.backgroundColor = self.toolBarBackColor;
    self.toolBarView.titleFont = self.toolBarTitleFont;
    self.toolBarView.titleColor = self.toolBarTitleColor;
    self.toolBarView.lineColor = self.toolBarLineColor;
    NSMutableArray *menus = [NSMutableArray array];
    for(LLVFunctionItem *item in self.toolBarItems){
        [menus addObject:@{@"icon":item.icon?item.icon:@"",@"title":item.title}];
    }
    [self.toolBarView loadMenuArr:menus];
    
    self.loadingView.backgroundColor = [LLVColorTool colorWithHexString:@"#ffffff"];
    self.loadingView.indicatorIcon = @"ll_indicator_loading";
    self.loadingView.loadIcon = @"ll_indicator_live_logo";
    self.loadingView.loadIconMarginY = 160.0;
    [self.loadingView loadWithState:LLVLoadingState_start withTitle:@"正在进入教室"];
    self.loadingView.loadLeftBtnClick = ^(UIButton *sender) {
        if(weakSelf.loadLeftBtnClick){
            weakSelf.loadLeftBtnClick(sender);
        }else{
            [[weakSelf viewController].navigationController popViewControllerAnimated:YES];
        }
    };
    
    //Segment View 默认选中
    if(self.segmentItems.count){
        [self doSelected:self.segmentItems.firstObject];
    }
    //loading视图在最上面
    [self bringSubviewToFront:self.loadingView];
}

- (void)fullViedoScreen
{

}

- (void)doSelected:(LLVFunctionItem *)item
{
    
}

//播放器高度
- (CGFloat)playerHeight
{
    if(_playerHeight == 0){
        _playerHeight = 281.0*self.deviceScale;
    }
    return _playerHeight;
}

- (CGFloat)docHeight
{
    if(_docHeight == 0){
        _docHeight = 212.0*self.deviceScale;
    }
    return _docHeight;
}

- (CGFloat)segHeight
{
    if(_segHeight == 0){
        _segHeight = 40.0;
    }
    return _segHeight;
}

- (CGFloat)navHeight
{
    if(_navHeight == 0){
        _navHeight = 64.0;
    }
    return _navHeight;
}

- (CGFloat)toolBarHeight
{
    if(_toolBarHeight == 0){
        _toolBarHeight = 50.0;
    }
    return _toolBarHeight;
}


- (NSString *)audioPlayHolderImage
{
    if(!_audioPlayHolderImage){
        _audioPlayHolderImage = @"ll_only_audio_bj";
    }
    return _audioPlayHolderImage;
}

- (UIColor *)segBackColor
{
    if(!_segBackColor){
        _segBackColor = [UIColor whiteColor];
    }
    return _segBackColor;
}

- (UIColor *)toolBarBackColor
{
    if(!_toolBarBackColor){
        _toolBarBackColor = [UIColor whiteColor];
    }
    return _toolBarBackColor;
}

- (void)fullViedoScreenFrom:(UIInterfaceOrientation)from to:(UIInterfaceOrientation)to
{
    
}

@end
