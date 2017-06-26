//
//  LLiveVideoView.m
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLiveVideoView.h"
#import "LLiveParam.h"

#import "LLiveToolView.h"
#import "LLVInputToolView.h"
#import "LLVChatTableView.h"
#import "LLVideoToolBar.h"

#import "LLVNetWorkKit.h"

@interface LLiveVideoView()<GSPPlayerManagerDelegate, GSPDocViewDelegate, LLVToolViewDelegate>
{
    CGRect videoViewRect;//记录videoView的原始尺寸
    CGRect docViewRect;//记录docView的原始尺寸
    
    BOOL isAllChat;
    BOOL isPersonalChat;
}
@property (nonatomic, strong) UIImageView *audioPlayHolder;//语音播放中...
@property (nonatomic, strong) GSPVideoView *videoView;//视频视图
@property (nonatomic, strong) GSPDocView *docView;//文档视图
@property (nonatomic, strong) LLVInputToolView *inputView;
@property (nonatomic, strong) LLVChatTableView *chatView;
@property (nonatomic, strong) GSPPlayerManager *playerManager;
@property (nonatomic, strong) NSMutableArray *userInfoArray;//参与聊天的用户
@property (nonatomic, strong) LLiveToolView *liveToolView;
@property (nonatomic, strong) LLVFunctionItem *currentSegmentItem;
@property (nonatomic, strong) UIAlertView *alert;
@end

@implementation LLiveVideoView
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

- (void)loadView
{
    [self setupSubViews];
}

- (void)setupSubViews
{
    //Video View
    videoViewRect = CGRectMake(0, 0, self.bounds.size.width, self.playerHeight);
    _videoView = [[GSPVideoView alloc]initWithFrame:videoViewRect];
    _videoView.contentMode = UIViewContentModeScaleAspectFit;
    _playerManager.videoView = _videoView;
    [self addSubview:_videoView];
    
    //双击 全屏
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotationVideoView:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [_videoView addGestureRecognizer:tapGestureRecognizer];
    
    //Nav View
    _navView = [[LLVideoNavView alloc] initWithFrame:(CGRect){CGPointZero, {self.bounds.size.width, self.navHeight}}];
    _navView.title = @"Tony直播";
    [_videoView addSubview:_navView];
    
    //Live Tool View
    __weak __typeof(&*self) weakSelf = self;
    _liveToolView = [LLiveToolView lLiveToolView];
    _liveToolView.frame = (CGRect){{0, _videoView.bounds.size.height - 36.0},{_videoView.bounds.size.width, 36.0}};
    _liveToolView.fullScreenBlock = ^(BOOL flag){
        [weakSelf fullViedoScreen];
    };
    _liveToolView.switchMediaBlock = ^(BOOL flag){
        [weakSelf.playerManager enableVideo:!flag];
        weakSelf.audioPlayHolder.hidden = !flag;
    };
    [_videoView addSubview:_liveToolView];
    
    //Segment View
    if(_segmentItems.count){
        _segmentView = [[LLVSegmentView alloc] initWithFrame:(CGRect){{0, CGRectGetMaxY(_videoView.frame)}, {self.bounds.size.width, self.segHeight}}];
    }
    [self addSubview:_segmentView];
    
    [self bringSubviewToFront:_videoView];
    
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
    
    _loadingView.loadBtnClick = ^(LLVLoadingState state){
        [weakSelf.loadingView loadWithState:LLVLoadingState_start withTitle:@"正在进入教室"];
        [weakSelf setLiveParam:weakSelf.liveParam];
    };
    
    //网络请求
    [[LLV_HttpManager shared] get:@"http://estudy.staff.xdf.cn/api.php/CourseGroup/index?appKey=CE804942A6D34511BBF4A935E0F7BF11&channelID=1001&courseId=4344" didFinished:^(LLV_BaseOperation * _Nullable operation, NSData * _Nullable data, NSError * _Nullable error, BOOL isSuccess) {
        
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",result);
        NSDictionary *json = [LLV_Json dictionaryWithJson:result];
        NSLog(@"%@", json);
    }];
}

- (void)doSelected:(LLVFunctionItem *)item
{
    _currentSegmentItem = item;
    
    if(!_docView){
        [self initDocView];
    }
    
    if(!_chatView){
        [self initChatView];
    }
    
    switch (item.type) {
        case FunctionType_doc:{
            _chatView.hidden = YES;_inputView.hidden = YES;
            _toolBarView.hidden = NO;_docView.hidden = NO;
        }
            break;
        case FunctionType_chat:{
            _docView.hidden = YES;_toolBarView.hidden = YES;
            _chatView.hidden = NO;_inputView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)initDocView
{
    //Doc View
    docViewRect = CGRectMake(15.0, CGRectGetMaxY(_segmentView.frame) + 14.0, self.bounds.size.width - 30.0, self.docHeight);
    _docView = [[GSPDocView alloc]initWithFrame:docViewRect];
    _docView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    [_docView setGlkBackgroundColor:51 green:51 blue:51];
    _docView.gSDocModeType = ScaleAspectFit;
    _docView.pdocDelegate = self;
    _docView.hidden = YES;
    _playerManager.docView = _docView;
    [self addSubview:_docView];
    
    //全屏
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotationdocView:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [_docView addGestureRecognizer:tapGestureRecognizer];
}

- (void)initChatView
{
    _chatView = [[LLVChatTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segmentView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(_segmentView.frame) - 50)];
    //用户相关信息
    GSPUserInfo *userInfo = [GSPUserInfo new];
    userInfo.userID = self.liveParam.customUserID;
    userInfo.userName = self.liveParam.nickName;
    _chatView.userInfo = userInfo;
    [self addSubview:_chatView];
    
    _inputView = [[LLVInputToolView alloc] initWithParentFrame:self.frame emojiPlistFileName:@"text2file" inBundle:[NSBundle mainBundle]];
    _inputView.backgroundColor = [UIColor whiteColor];
    _inputView.delegate = self;
    
    [self addSubview:_inputView];
}

- (void)rotationVideoView:(UIGestureRecognizer *)ges
{
    [self fullViedoScreen];
}

//文档旋转屏
- (void)fullViedoScreen
{
    if(_hasOrientation){
        [self fullViedoScreenFrom:UIInterfaceOrientationLandscapeRight to:UIInterfaceOrientationPortrait];
    }else{
        [self bringSubviewToFront:_videoView];
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
        [self bringSubviewToFront:_docView];
        [self docTransformRotate:M_PI_2 frame:[UIScreen mainScreen].bounds statusBarOrientation:(UIInterfaceOrientationLandscapeRight) isHiddrenDarkView:NO];
        _hasOrientation = YES;
    }
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
        CGAffineTransform transform = CGAffineTransformRotate(_videoView.transform, pi);
        _videoView.transform = transform;
        _videoView.frame = frame;
        _audioPlayHolder.frame = _videoView.bounds;
        
        _navView.frame = (CGRect){CGPointZero, {_videoView.bounds.size.width, self.navHeight}};
        _liveToolView.frame = (CGRect){{0, _videoView.bounds.size.height - 36.0},{_videoView.bounds.size.width, 36.0}};
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
        CGAffineTransform transform = CGAffineTransformRotate(_docView.transform, pi);
        _docView.transform = transform;
        _docView.frame = frame;
        
    } completion:^(BOOL finished) {
        if(orientation == UIInterfaceOrientationPortrait){
            [UIApplication sharedApplication].statusBarHidden = NO;
        }
    }];
}

#pragma mark - setter method
- (void)setLiveParam:(LLiveParam *)liveParam
{
    if(_liveParam != liveParam){
        _liveParam = liveParam;
    }
    
    //判断加入是否成功
    if (!_playerManager) {
        _playerManager = [GSPPlayerManager new];
        _playerManager.delegate = self;
    }
    GSPJoinParam *joinParam = [_liveParam gspJoinParam];
    joinParam.oldVersion = NO;
    
    [_playerManager joinWithParam:joinParam];
}

#pragma mark - GHToolViewDelegate 
- (void)sendMessage:(NSString *)content
{
    GSPChatMessage *message = [[GSPChatMessage alloc] init];
    message.text = content;
    NSDate *datenow = [NSDate date];
    message.receiveTime = (long)[datenow timeIntervalSince1970];
    message.senderUserID = self.liveParam.customUserID;
    //转义  <  >
    message.richText = [content stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    message.richText = [message.richText stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    message.richText = [_chatView chatString:message.richText];
    message.richText = [message.richText stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<BR>"];
    message.richText = [message.richText stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR>"];
    message.msgID = [[NSUUID UUID] UUIDString];//消息ID
    
    if ([[GSPPlayerManager sharedManager] chatWithAll:message]) {
        [_chatView reloadWithMessage:message];
    }
}

#pragma mark - GSPPlayerManagerDelegate
- (void)playerManager:(GSPPlayerManager *)playerManager didSelfLeaveFor:(GSPLeaveReason)reason {
    NSString *reasonStr = nil;
    switch (reason) {
        case GSPLeaveReasonEjected:
            reasonStr = NSLocalizedString(@"被踢出直播", @"");
            break;
        case GSPLeaveReasonTimeout:
            reasonStr = NSLocalizedString(@"超时", @"");
            break;
        case GSPLeaveReasonClosed:
            reasonStr = NSLocalizedString(@"直播关闭", @"");
            break;
        case GSPLeaveReasonUnknown:
            reasonStr = NSLocalizedString(@"位置错误", @"");
            break;
        default:
            break;
    }
    if (reasonStr != nil) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"退出直播", @"") message:reasonStr delegate:self cancelButtonTitle:NSLocalizedString(@"知道了", @"") otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)playerManager:(GSPPlayerManager *)playerManager didReceiveSelfJoinResult:(GSPJoinResult)joinResult {
    NSString *result = @"";
    switch (joinResult) {
        case GSPJoinResultCreateRtmpPlayerFailed:{
            result = NSLocalizedString(@"创建直播实例失败", @"");
        }
            break;
        case GSPJoinResultJoinReturnFailed:{
            result = NSLocalizedString(@"调用加入直播失败", @"");
        }
            break;
        case GSPJoinResultNetworkError:{
            result = NSLocalizedString(@"网络错误", @"");
            [self.loadingView loadWithState:LLVLoadingState_netFail withTitle:@"连接失败，请切换网络并尝试刷新"];
        }
            break;
        case GSPJoinResultUnknowError:{
            result = NSLocalizedString(@"未知错误", @"");
            [self.loadingView loadWithState:LLVLoadingState_otherError withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
        }
            break;
        case GSPJoinResultParamsError:{
            result = NSLocalizedString(@"参数错误", @"");
            [self.loadingView loadWithState:LLVLoadingState_otherError withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
        }
            break;
        case GSPJoinResultOK:{
            result = @"加入成功";
            [self.loadingView loadWithState:LLVLoadingState_sucess withTitle:nil];
        }
            break;
        case GSPJoinResultCONNECT_FAILED:{
            result = NSLocalizedString(@"连接失败", @"");
            [self.loadingView loadWithState:LLVLoadingState_netFail withTitle:@"连接失败，请切换网络并尝试刷新"];
        }
            break;
        case GSPJoinResultTimeout:{
            result = NSLocalizedString(@"连接超时", @"");
            [self.loadingView loadWithState:LLVLoadingState_netFail withTitle:@"连接失败，请切换网络并尝试刷新"];
        }
            break;
        case GSPJoinResultRTMP_FAILED:{
            result = NSLocalizedString(@"链接媒体服务器失败", @"");
            [self.loadingView loadWithState:LLVLoadingState_netFail withTitle:@"连接失败，请切换网络并尝试刷新"];
        }
            break;
        case GSPJoinResultTOO_EARLY:{
            result = NSLocalizedString(@"直播尚未开始", @"");
            [self.loadingView loadWithState:LLVLoadingState_offLine withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
        }
            break;
        case GSPJoinResultLICENSE:{
            result = NSLocalizedString(@"人数已满", @"");
            [self.loadingView loadWithState:LLVLoadingState_otherError withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
        }
            break;
        default:{
            result = NSLocalizedString(@"未知错误", @"");
            [self.loadingView loadWithState:LLVLoadingState_otherError withTitle:[NSString stringWithFormat:@"%@，请稍后尝试刷新",result]];
        }
            break;
    }
}

- (void)playerManagerWillReconnect:(GSPPlayerManager *)playerManager {
    [self endEditing:YES];
}

/**
 *  在线人数
 *
 *  @param playerManager 调用该代理的直播管理实例
 *  @param num           在线总人数
 */
- (void)playerManager:(GSPPlayerManager*)playerManager onlineNum:(NSUInteger)num
{
    _liveToolView.onlineCount = num;
}

/**
 *  直播聊天权限改变代理
 *
 *  @param playerManager 调用该代理的直播管理实例
 *  @param bEnable       整个直播是否支持聊天
 */
- (void)playerManager:(GSPPlayerManager*)playerManager didSetChatEnable:(BOOL)bEnable
{
    if (!bEnable) {
        isAllChat = NO;
        
        GSPChatMessage *message = [[GSPChatMessage alloc]init];
        message.senderName = NSLocalizedString(@"系统消息", @"");
        message.richText = NSLocalizedString(@"房间现在禁止聊天", @"");
        message.text = NSLocalizedString(@"房间现在禁止聊天", @"");
        message.chatType = GSPChatTypeSystem;
        [self.chatView reloadWithMessage:message];
        return;
    }
    
    isAllChat = YES;
    if (isPersonalChat) {
        
    }else {
        
    }
    GSPChatMessage *message = [[GSPChatMessage alloc]init];
    message.senderName = NSLocalizedString(@"系统消息", @"");
    message.richText = NSLocalizedString(@"房间现在允许聊天", @"");
    message.text = NSLocalizedString(@"房间现在允许聊天", @"");
    message.chatType = GSPChatTypeSystem;
    [self.chatView reloadWithMessage:message];
}

- (void)playerManager:(GSPPlayerManager *)playerManager didUserJoin:(GSPUserInfo *)userInfo {
    if (userInfo.userID != playerManager.selfUserInfo.userID) {
        [_userInfoArray addObject:userInfo];
    }
}

- (void)playerManager:(GSPPlayerManager*)playerManager isSelfMute:(BOOL)bMute
{
    
}

//chatView
- (void)playerManager:(GSPPlayerManager *)playerManager didUserLeave:(GSPUserInfo *)userInfo {
    
}

/**
 *  收到聊天信息代理
 *
 *  @param playerManager 调用该代理的直播管理实例
 *  @param message       收到的聊天信息
 */
- (void)playerManager:(GSPPlayerManager*)playerManager didReceiveChatMessage:(GSPChatMessage*)message
{
    NSLog(@"didReceiveChatMessage******");
    [self.chatView reloadWithMessage:message];
}

/**
 *  直播是否暂停
 *
 *  @param playerManager 调用该代理的直播管理实例
 *  @param isPaused      YES表示直播已暂停，NO表示直播进行中
 */
- (void)playerManager:(GSPPlayerManager*)playerManager isPaused:(BOOL)isPaused
{
    NSLog(@"isPaused******");
}

- (void)playerManager:(GSPPlayerManager *)playerManager  didReceiveMediaInvitation:(GSPMediaInvitationType)type action:(BOOL)on
{
    [_alert dismissWithClickedButtonIndex:1 animated:YES];
    if (GSPMediaInvitationTypeAudioOnly == type) {
        if (on) {
            if (!_alert) {
                _alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"直播间邀请您语音对话", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"拒绝", nil) otherButtonTitles:NSLocalizedString(@"接受", nil), nil];
                _alert.tag = 999;
            }
            [_alert show];
        }
        else{
            [playerManager activateMicrophone:NO];
            [playerManager acceptMediaInvitation:NO type:type];
        }
    }
}

- (void)playerManager:(GSPPlayerManager *)playerManager  didReceiveMediaScreenStatus:(BOOL)bIsOpen
{
    NSLog(@"didReceiveMediaScreenStatus=%d",bIsOpen);
    
}

- (void)playerManager:(GSPPlayerManager *)playerManager  didReceiveMediaModuleFocus:(GSModuleFocusType)focus
{
    NSLog(@"didReceiveMediaModuleFocus=%lu",(unsigned long)focus);
}

//直播未开始返回
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999 && buttonIndex == 1) {
        [self.playerManager activateMicrophone:YES];
        [self.playerManager acceptMediaInvitation:YES type:GSPMediaInvitationTypeAudioOnly];
    }else if (alertView.tag == 999 && buttonIndex == 0) {
        [self.playerManager acceptMediaInvitation:NO type:GSPMediaInvitationTypeAudioOnly];
    }
}

- (BOOL)sendChatMessage:(GSPChatMessage *)chatMessage
{
    return [_playerManager chatWithAll:chatMessage];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint myPoint = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, myPoint)) {
                return subView;
            }
        }
    }
    return view;
}

#pragma mark - getter method
- (UIImageView *)audioPlayHolder
{
    if(!_audioPlayHolder){
        _audioPlayHolder = [[UIImageView alloc] init];
        _audioPlayHolder.frame = self.videoView.bounds;
        _audioPlayHolder.image = [UIImage imageNamed:self.audioPlayHolderImage];
        _audioPlayHolder.contentMode = UIViewContentModeScaleAspectFill;
        _audioPlayHolder.layer.masksToBounds = YES;
        [_videoView addSubview:_audioPlayHolder];
        [_videoView bringSubviewToFront:_navView];
        [_videoView bringSubviewToFront:_liveToolView];
    }
    return _audioPlayHolder;
}

#pragma mark -
- (void)dealloc {
    [self.playerManager activateMicrophone:NO];
    [self.playerManager leave];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark ----GSPDocViewDelegate-----
- (void)docViewPOpenFinishSuccess:(GSPDocPage*)page   docID:(unsigned)docID
{
    if (_docView.hidden && !_hasOrientation && _currentSegmentItem.type == FunctionType_doc) {
        _docView.hidden=NO;
    }
}

@end
