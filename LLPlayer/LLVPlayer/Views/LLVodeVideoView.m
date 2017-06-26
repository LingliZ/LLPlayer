//
//  LLVodeVideoView.m
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVodeVideoView.h"
#import <PlayerSDK/VodPlayer.h>
#import <PlayerSDK/downItem.h>
#import <PlayerSDK/GSVodDocView.h>
#import "sys/utsname.h"
#import <AVFoundation/AVFoundation.h>
#import "LLVodParam.h"
#import "LLVFunctionItem.h"

#import "LLVSegmentView.h"
#import "LLVodeToolView.h"
#import "LLVChatTableView.h"
#import "LLVLessonTableView.h"
@interface LLVodeVideoView()<VodPlayDelegate,VodDownLoadDelegate,GSVodDocViewDelegate>
{
    CGRect videoViewRect;
    CGRect docViewRect;
    int last;
}
@property (nonatomic, strong) VodPlayer *vodplayer;
//参与聊天的用户
@property (nonatomic, strong) NSMutableArray *userInfoArray;

@property (nonatomic, strong) VodDownLoader *voddownloader;

@property (nonatomic, strong) LLVodeToolView *vodeToolView;

@property (nonatomic, strong) NSString *vodTotalTime;//点播的总时间

@property (nonatomic, assign) BOOL isVideoFinished;

@property (nonatomic, assign) float videoRestartValue;

@property (nonatomic, strong) LLVChatTableView *chatView;//聊天列表

@property (nonatomic, strong) LLVLessonTableView *lessonListView;//课节列表

@property (nonatomic, strong) LLVFunctionItem *currentSegmentItem;

@end

@implementation LLVodeVideoView
@synthesize navView = _navView;
@synthesize segmentItems = _segmentItems;
@synthesize segmentView = _segmentView;
@synthesize hasOrientation = _hasOrientation;
@synthesize loadingView = _loadingView;
@synthesize toolBarItems = _toolBarItems;
@synthesize toolBarView = _toolBarView;
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self initData];
    }
    return self;
}

- (void)initData
{
    _userInfoArray = [[NSMutableArray alloc] init];
}


- (void)setVodParam:(LLVodParam *)vodParam
{
    if(_vodParam != vodParam){
        _vodParam = vodParam;
    }
    
    if (!_voddownloader) {
        _voddownloader = [[VodDownLoader alloc]init];
        _voddownloader.delegate = self;
    }
    
    [self.voddownloader addItem:[_vodParam vodParam]];
}

- (void)loadView
{
    [self setupSubViews];
}

- (void)setupSubViews
{
    videoViewRect = CGRectMake(0, 0, self.bounds.size.width, self.playerHeight);
    
    self.vodplayer = [[VodPlayer alloc] init];
    
    //Video
    self.vodplayer.mVideoView = [[VodGLView alloc] initWithFrame:videoViewRect];
    self.vodplayer.mVideoView.contentMode = UIViewContentModeScaleAspectFit;
    self.vodplayer.mVideoView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.vodplayer.mVideoView];//视频
    //双击 全屏
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotationVideoView:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.vodplayer.mVideoView addGestureRecognizer:tapGestureRecognizer];
    
    //Nav View
    _navView = [[LLVideoNavView alloc] initWithFrame:(CGRect){CGPointZero, {self.bounds.size.width, self.navHeight}}];
    _navView.title = @"Tony回播";
    [_vodplayer.mVideoView addSubview:_navView];
    
    //Live Tool View
    __weak __typeof(&*self) weakSelf = self;
    _vodeToolView = [LLVodeToolView lLVodeToolView];
    _vodeToolView.frame = (CGRect){{0, _vodplayer.mVideoView.bounds.size.height - 36.0},{_vodplayer.mVideoView.bounds.size.width, 36.0}};
    _vodeToolView.image = [UIImage imageNamed:@"ll_player_mask_bg2"];
    _vodeToolView.fullScreenBlock = ^(BOOL flag){
        [weakSelf fullViedoScreen];
    };
    _vodeToolView.sliderSeekBlock = ^(CGFloat value){
        if (weakSelf.isVideoFinished) {
            [weakSelf.vodplayer OnlinePlay:NO audioOnly:NO];
            weakSelf.vodeToolView.playBtn.selected = !weakSelf.vodeToolView.playBtn.selected;
        }
        weakSelf.videoRestartValue = value;
        [weakSelf.vodplayer seekTo:weakSelf.videoRestartValue];
    };
    _vodeToolView.playVideoBlock = ^(BOOL flag){
        if (weakSelf.vodplayer) {
            if(flag){
                if(weakSelf.isVideoFinished){
                    [weakSelf.vodplayer OnlinePlay:NO audioOnly:NO];
                    weakSelf.videoRestartValue = 0;
                    [weakSelf.vodplayer seekTo:weakSelf.videoRestartValue];
                }else{
                    [weakSelf.vodplayer resume];
                }
            }else{
                [weakSelf.vodplayer pause];
            }
        }
    };
    [_vodplayer.mVideoView addSubview:_vodeToolView];
    
    //Segment View
    if(_segmentItems.count){
        _segmentView = [[LLVSegmentView alloc] initWithFrame:(CGRect){{0, CGRectGetMaxY(_vodplayer.mVideoView.frame)}, {self.bounds.size.width, self.segHeight}}];
    }
    [self addSubview:_segmentView];
    
    [self bringSubviewToFront:_vodplayer.mVideoView];
    
    //底部工具栏
    if(_toolBarItems.count){
        _toolBarView = [[LLVideoToolBar alloc] initWithFrame:(CGRect){{0, self.bounds.size.height - self.toolBarHeight}, {self.bounds.size.width, self.toolBarHeight}}];
    }
    [self addSubview:_toolBarView];
    
    //等待框
    _loadingView = [[LLVLoadingView alloc] initWithFrame:self.bounds];
    [self addSubview:_loadingView];
    
    //调用父视图加载统一数据
    [super loadView];
    
    self.loadingView.loadBtnClick = ^(LLVLoadingState state){
        [weakSelf.loadingView loadWithState:LLVLoadingState_start withTitle:@"正在进入教室"];
        [weakSelf setVodParam:weakSelf.vodParam];
    };
}

- (void)doSelected:(LLVFunctionItem *)item
{
    _currentSegmentItem = item;
    
    if(!_vodplayer.docSwfView){
        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %d",@"type",FunctionType_doc];
        if([[_segmentItems filteredArrayUsingPredicate:predicateString] firstObject]){
            [self initDocView];
        }
    }
    
    if(!_chatView){
        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %d",@"type",FunctionType_chat];
        if([[_segmentItems filteredArrayUsingPredicate:predicateString] firstObject]){
            [self initChatView];
        }
    }
    
    if(!_lessonListView){
        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %d",@"type",FunctionType_lesson];
        if([[_segmentItems filteredArrayUsingPredicate:predicateString] firstObject]){
             [self initLessonListView];
        }
    }
    
    switch (item.type) {
        case FunctionType_doc:{
            _chatView.hidden = YES;_lessonListView.hidden = YES;
            _vodplayer.docSwfView.hidden = NO;
        }
            break;
        case FunctionType_lesson:
        {
            _vodplayer.docSwfView.hidden = YES;_chatView.hidden = YES;
            _lessonListView.hidden = NO;
        }
            break;
        case FunctionType_chat:{
            _vodplayer.docSwfView.hidden = YES;_lessonListView.hidden = YES;
            _chatView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)initDocView
{
    docViewRect = CGRectMake(15.0, CGRectGetMaxY(_segmentView.frame) + 14.0, self.bounds.size.width - 30.0, self.docHeight);
    
    //Doc
    self.vodplayer.docSwfView = [[GSVodDocView alloc] initWithFrame:docViewRect];
    self.vodplayer.delegate = self;
    self.vodplayer.docSwfView.vodDocDelegate=self;
    self.vodplayer.docSwfView.gSDocModeType = VodScaleAspectFit;
    [self.vodplayer.docSwfView setGlkBackgroundColor:51 green:51 blue:51];//文档加载以后，侧边显示的颜色
    self.vodplayer.docSwfView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    [self addSubview:self.vodplayer.docSwfView];//文档
    //全屏
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotationdocView:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.vodplayer.docSwfView addGestureRecognizer:tapGestureRecognizer];
}

- (void)initChatView
{
    _chatView = [[LLVChatTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segmentView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(_segmentView.frame) - _toolBarView.bounds.size.height)];
    //用户相关信息
    GSPUserInfo *userInfo = [GSPUserInfo new];
    _chatView.userInfo = userInfo;
    [self addSubview:_chatView];
}

- (void)initLessonListView
{
    _lessonListView = [[LLVLessonTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segmentView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(_segmentView.frame) - _toolBarView.bounds.size.height)];
    __weak __typeof(&*self) weakSelf = self;
    _lessonListView.lessonCellSelectedBlcok = ^(NSDictionary *info){//点击课节列表
        long value = [[info objectForKey:@"timestamp"] intValue];
        if (weakSelf.isVideoFinished) {
            [weakSelf.vodplayer OnlinePlay:NO audioOnly:NO];
        }
        weakSelf.vodeToolView.playBtn.selected = NO;//播放状态
        weakSelf.videoRestartValue = value;
        [weakSelf.vodplayer seekTo:weakSelf.videoRestartValue];
    };
    [self addSubview:_lessonListView];
}

- (void)rotationVideoView:(UIGestureRecognizer *)ges
{
    [self fullViedoScreen];
}

- (void)fullViedoScreen
{
    if(_hasOrientation){
        [self fullViedoScreenFrom:UIInterfaceOrientationLandscapeRight to:UIInterfaceOrientationPortrait];
    }else{
        [self bringSubviewToFront:_vodplayer.mVideoView];
        [self fullViedoScreenFrom:UIInterfaceOrientationPortrait to:UIInterfaceOrientationLandscapeRight];
    }
}

//文档旋转屏
- (void)rotationdocView:(UIGestureRecognizer *)gestureRecognizer {
    //强制旋转
    if (_hasOrientation) {
        [self docTransformRotate:-M_PI_2 frame:docViewRect statusBarOrientation:(UIInterfaceOrientationPortrait) isHiddrenDarkView:YES];
        _hasOrientation = NO;
    } else {
        [self bringSubviewToFront:_vodplayer.docSwfView];
        [self docTransformRotate:M_PI_2 frame:[UIScreen mainScreen].bounds statusBarOrientation:(UIInterfaceOrientationLandscapeRight) isHiddrenDarkView:NO];
        _hasOrientation = YES;
    }
}

- (NSString *)currentPlayTime:(int)position {
    if (!_vodTotalTime) {
        _vodTotalTime = @"00:00";
    }
    return [NSString stringWithFormat:@"%@/%@",[LLVPublicTool formatVProgressTime:position],_vodTotalTime];
}

#pragma mark - VodDownLoadDelegate
//添加item的回调方法
- (void)onAddItemResult:(RESULT_TYPE)resultType voditem:(downItem *)item
{
    NSString *result = @"";
    if (resultType == RESULT_SUCCESS) {
        result = @"加入成功";
        _item = item;
        //在线播放
        downItem *Litem = [[VodManage shareManage]findDownItem:_item.strDownloadID];
        if(Litem){
            self.vodplayer.playItem = Litem;
        }
        [self.vodplayer OnlinePlay:YES audioOnly:NO];
        
        [self.loadingView loadWithState:LLVLoadingState_sucess withTitle:nil];
    }else if (resultType == RESULT_ROOM_NUMBER_UNEXIST){
        result = NSLocalizedString(@"点播间不存在" ,@"");
        [self.loadingView loadWithState:LLVLoadingState_otherError withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
    }else if (resultType == RESULT_FAILED_NET_REQUIRED){
        result = NSLocalizedString(@"网络请求失败" ,@"");
        [self.loadingView loadWithState:LLVLoadingState_netFail withTitle:@"连接失败，请切换网络并尝试刷新"];
    }else if (resultType == RESULT_FAIL_LOGIN){
        result = NSLocalizedString(@"用户名或密码错误" ,@"");
        [self.loadingView loadWithState:LLVLoadingState_otherError withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
    }else if (resultType == RESULT_NOT_EXSITE){
        result = NSLocalizedString(@"该点播的编号的点播不存在" ,@"");
        [self.loadingView loadWithState:LLVLoadingState_otherError withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
    }else if (resultType == RESULT_INVALID_ADDRESS){
        result = NSLocalizedString(@"无效地址" ,@"");
        [self.loadingView loadWithState:LLVLoadingState_otherError withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
    }else if (resultType == RESULT_UNSURPORT_MOBILE){
        result = NSLocalizedString(@"不支持移动设备" ,@"");
        [self.loadingView loadWithState:LLVLoadingState_otherError withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
    }else if (resultType == RESULT_FAIL_TOKEN){
        result = NSLocalizedString(@"口令错误" ,@"");
        [self.loadingView loadWithState:LLVLoadingState_otherError withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
    }
}

#pragma mark -VodPlayDelegate
//初始化VodPlayer代理
- (void)onInit:(int)result haveVideo:(BOOL)haveVideo duration:(int)duration docInfos:(NSArray *)docInfos
{
    _vodeToolView.maxProgressValue = duration;
    _vodeToolView.miniProgressValue = 0;
    
    //播放结束
    if (self.isVideoFinished) {
        self.isVideoFinished = NO;
        //从设定好的位置开始
        [self.vodplayer seekTo:self.videoRestartValue];
    }
    
    _vodTotalTime = [LLVPublicTool formatVProgressTime:duration];
    
    //文档信息
    if(docInfos.count){
        NSMutableArray *lessons = [NSMutableArray array];
        for(NSDictionary *docInfo in docInfos){
            NSArray *array = [docInfo objectForKey:@"pages"];
            for(NSDictionary *lesson in array){
                NSMutableDictionary *lessonInfo = [NSMutableDictionary dictionaryWithDictionary:lesson];
                [lessonInfo setValue:[NSNumber numberWithLong:duration] forKey:@"duration"];
                [lessons addObject:lessonInfo];
            }
        }
        _lessonListView.data = lessons;
    }
    
    if(_chatView){
        [_vodplayer getChatListWithPageIndex:1];//获取聊天列表数据，一次获取200条
    }
}

/**
 * 文档信息回调
 */
- (void)onDocInfo:(NSArray*)docInfos
{
    
}

//进度条定位播放，如快进、快退、拖动进度条等操作回调方法
- (void)onSeek:(int) position
{
    [_vodeToolView setProgressValue:MAX(position, self.videoRestartValue) animated:YES];
    _vodeToolView.timeTitleStr= [self currentPlayTime:MAX(position, self.videoRestartValue)];
}

//进度回调方法
- (void)onPosition:(int)position
{
    [_vodeToolView setProgressValue:position animated:YES];
    _vodeToolView.timeTitleStr = [self currentPlayTime:position];
}

- (void) onAnnotaion:(int)position
{
    _vodeToolView.timeTitleStr = [self currentPlayTime:position];
}

- (void)onVideoStart
{
    
}

//播放完成停止通知，
- (void)onStop{
    self.isVideoFinished = YES;
    self.vodeToolView.timeTitleStr = [NSString stringWithFormat:@"%@/%@",_vodTotalTime,_vodTotalTime];
    self.vodeToolView.playBtn.selected = !self.vodeToolView.playBtn.selected;
}

- (void)OnChat:(NSArray *)chatArray
{
//    [_chatView reloadWithVodChats:chatArray];
}

/*
 *获取聊天列表
 *@chatList   列表数据 (sender: 发送者  text : 聊天内容   time： 聊天时间)
 *
 */
- (void)vodRecChatList:(NSArray*)chatList more:(BOOL)more currentPageIndex:(int)pageIndex
{
    NSLog(@"didReceiveChatMessage******");
    [self.chatView reloadWithVodChatDics:chatList];
}

/*
 *获取问题列表
 *@qaList   列表数据 （answer：回答内容 ; answerowner：回答者 ; id：问题id ;qaanswertimestamp:问题回答时间 ;question : 问题内容  ，questionowner:提问者 questiontimestamp：提问时间）
 *
 */
- (void)vodRecQaList:(NSArray*)qaList more:(BOOL)more currentPageIndex:(int)pageIndex
{
    
}

- (void)fullViedoScreenFrom:(UIInterfaceOrientation)from to:(UIInterfaceOrientation)to
{
    switch (to) {
        case UIInterfaceOrientationLandscapeRight:
        {
            _hasOrientation = YES;
            [self videoTransformRotate:M_PI_2 frame:[UIScreen mainScreen].bounds statusBarOrientation:(UIInterfaceOrientationLandscapeRight) isHiddrenDarkView:NO];
        }
            break;
        case UIInterfaceOrientationPortrait:
        {
            _hasOrientation = NO;
            [self videoTransformRotate:-M_PI_2 frame:videoViewRect statusBarOrientation:(UIInterfaceOrientationPortrait) isHiddrenDarkView:YES];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            _hasOrientation = YES;
            [self videoTransformRotate:M_PI_2 frame:videoViewRect statusBarOrientation:(UIInterfaceOrientationPortrait) isHiddrenDarkView:YES];
        }
            break;
        default:
            break;
    }
}

/**
 *  该方法为控制controller.view 旋转的方法
 *
 *  @param pi          旋转弧度
 *  @param frame       旋转后的frame
 *  @param orientation 旋转后status的方向
 *  @param isHiddren   旋转完成后是否显示后面的黑色视图
 */
- (void)videoTransformRotate:(CGFloat)pi
                      frame:(CGRect)frame
       statusBarOrientation:(UIInterfaceOrientation)orientation
          isHiddrenDarkView:(BOOL)isHiddren {
    [UIApplication sharedApplication].statusBarHidden = YES;
    [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
        CGAffineTransform transform = CGAffineTransformRotate(self.vodplayer.mVideoView.transform, pi);
        self.vodplayer.mVideoView.transform = transform;
        self.vodplayer.mVideoView.frame = frame;
        
        _navView.frame = (CGRect){CGPointZero, {_vodplayer.mVideoView.bounds.size.width, self.navHeight}};
        _vodeToolView.frame = (CGRect){{0, _vodplayer.mVideoView.bounds.size.height - 36.0},{_vodplayer.mVideoView.bounds.size.width, 36.0}};
    } completion:^(BOOL finished) {
        if(orientation == UIInterfaceOrientationPortrait){
            [UIApplication sharedApplication].statusBarHidden = NO;
        }
    }];
}

- (void)docTransformRotate:(CGFloat)pi
                     frame:(CGRect)frame
      statusBarOrientation:(UIInterfaceOrientation)orientation
         isHiddrenDarkView:(BOOL)isHiddren {
    [UIApplication sharedApplication].statusBarHidden = YES;
    [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
        CGAffineTransform transform = CGAffineTransformRotate(self.vodplayer.docSwfView.transform, pi);
        self.vodplayer.docSwfView.transform = transform;
        self.vodplayer.docSwfView.frame = frame;
        
    } completion:^(BOOL finished) {
        if(orientation == UIInterfaceOrientationPortrait){
            [UIApplication sharedApplication].statusBarHidden = NO;
        }
    }];
}

#pragma mark -
- (void)dealloc {
    [self.vodplayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
