//
//  LiveVideoView.m
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLiveVideoView.h"
#import "LLiveParam.h"
#import "LLSegmentView.h"
#import "LLSegmentItem.h"
#import "LLiveToolView.h"

#import "GHInputToolView.h"
#import "LLChatTableView.h"

#import "LLColorTool.h"
#import "UIView+LLExtension.h"
@interface LLiveVideoView()<GSPPlayerManagerDelegate, GSPDocViewDelegate, GHToolViewDelegate>
{
    CGRect videoViewRect;//记录videoView的原始尺寸
    CGRect docViewRect;//记录docView的原始尺寸
    BOOL hasOrientation;
    
    BOOL isAllChat;
    BOOL isPersonalChat;
}
@property (nonatomic, strong) UIImageView *audioPlayHolder;//语音播放中...
@property (nonatomic, strong) GSPVideoView *videoView;//视频视图
@property (nonatomic, strong) GSPDocView *docView;//文档视图
@property (nonatomic, strong) GHInputToolView *inputView;
@property (nonatomic, strong) LLChatTableView *chatView;
@property (nonatomic, strong) GSPPlayerManager *playerManager;
@property (nonatomic, strong) NSMutableArray *userInfoArray;
@property (nonatomic, strong) LLSegmentView *segmentView;
@property (nonatomic, strong) LLiveToolView *liveToolView;
@property (nonatomic, strong) LLSegmentItem *currentSegmentItem;
@property (nonatomic, strong) UIAlertView *alert;
@end

@implementation LLiveVideoView
@synthesize navView = _navView;
@synthesize segmentItems = _segmentItems;
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
    hasOrientation = NO;
    
    [self setupSubViews];
}

- (void)setupSubViews
{
    self.backgroundColor = [LLColorTool colorWithHexString:@"#f2f2f2"];
    
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
    if(!_navView){
        _navView = [[LLVideoNavView alloc] initWithFrame:(CGRect){CGPointZero, {self.bounds.size.width, self.navHeight}}];
        _navView.title = @"Tony直播";
    }
    [self addSubview:_navView];
    
    //Live Tool View
    if(!_liveToolView){
        _liveToolView = [LLiveToolView lLiveToolView];
        _liveToolView.frame = (CGRect){{0, _videoView.bounds.size.height - 36.0},{_videoView.bounds.size.width, 36.0}};
        __weak __typeof(&*self) weakSelf = self;
        _liveToolView.fullScreenBlock = ^(BOOL flag){
            if(weakSelf.fullScreenBlock){
                weakSelf.fullScreenBlock(flag);
            }
        };
        _liveToolView.switchMediaBlock = ^(BOOL flag){
            [weakSelf.playerManager enableVideo:!flag];
            weakSelf.audioPlayHolder.hidden = !flag;
        };
    }
    [self addSubview:_liveToolView];
    
    //Segment View
    if(_segmentItems.count){
        _segmentView = [[LLSegmentView alloc] initWithFrame:(CGRect){{0, CGRectGetMaxY(_videoView.frame)}, {self.bounds.size.width, self.segHeight}}];
        _segmentView.backgroundColor = self.segBackColor;
        _segmentView.titleFont = self.segTitleFont;
        _segmentView.titleColor = self.segTitleColor;
        _segmentView.highlightTitleColor = self.segHighlightTitleColor;
        _segmentView.indicatorColor = self.segIndicatorColor;
        _segmentView.lineColor = self.segLineColor;
        NSMutableArray *titles = [NSMutableArray array];
        for(LLSegmentItem *item in _segmentItems){
            [titles addObject:item.title];
        }
        [_segmentView loadMenuArr:titles type:SEGMENT_TYPE_SEGMENT];
        __weak __typeof(&*self) weakSelf = self;
        [_segmentView addSelectedBlock:^(LLSegmentView *view, NSInteger selectedIndex, NSInteger lastSelectedIndex) {
            if(selectedIndex != lastSelectedIndex){
                [weakSelf doSelected:[weakSelf.segmentItems objectAtIndex:selectedIndex]];
            }
        }];
        [self addSubview:_segmentView];
        
        //默认选中
        [self doSelected:_segmentItems.firstObject];
    }
}

- (void)doSelected:(LLSegmentItem *)item
{
    _currentSegmentItem = item;
    
    if(!_docView){
        [self initDocView];
    }
    
    if(!_chatView){
        [self initChatView];
    }
    
    switch (item.type) {
        case SegmentItmeType_live_doc:{
            _chatView.hidden = YES;
            _inputView.hidden = YES;
            _docView.hidden = NO;
        }
            break;
        case SegmentItmeType_live_chat:{
            _docView.hidden = YES;
            _chatView.hidden = NO;
            _inputView.hidden = NO;
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
    _chatView = [[LLChatTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segmentView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(_segmentView.frame) - 50)];
    //用户相关信息
    GSPUserInfo *userInfo = [GSPUserInfo new];
    userInfo.userID = self.liveParam.customUserID;
    userInfo.userName = self.liveParam.nickName;
    _chatView.userInfo = userInfo;
    [self addSubview:_chatView];
    
    _inputView = [[GHInputToolView alloc] initWithParentFrame:self.frame emojiPlistFileName:@"text2file" inBundle:[NSBundle mainBundle]];
    _inputView.backgroundColor = [UIColor whiteColor];
    _inputView.delegate = self;
    
    [self addSubview:_inputView];
}

- (void)rotationVideoView:(UIGestureRecognizer *)ges
{
    if(_fullScreenBlock){
        _fullScreenBlock(!hasOrientation);
    }
}

- (void)fullViedoScreen:(BOOL)flag
{
    //强制旋转
    if (flag) {
        [UIView animateWithDuration:0.5 animations:^{//重置子元素frame
            _videoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            _liveToolView.frame = (CGRect){{0, _videoView.bounds.size.height - 36.0},{_videoView.bounds.size.width, 36.0}};
            _navView.frame = (CGRect){CGPointZero, {_videoView.bounds.size.width, self.navHeight}};
            _audioPlayHolder.frame = _videoView.bounds;
            _segmentView.frame = (CGRect){{0, CGRectGetMaxY(_videoView.frame)}, {_videoView.bounds.size.width, self.segHeight}};
            
            hasOrientation = YES;
            self.segmentView.hidden = YES;
            self.chatView.hidden = YES;
            self.docView.hidden = YES;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{//重置子元素frame
            _videoView.frame = videoViewRect;
            _liveToolView.frame = (CGRect){{0, _videoView.bounds.size.height - 36.0},{_videoView.bounds.size.width, 36.0}};
            _navView.frame = (CGRect){CGPointZero, {self.bounds.size.width, self.navHeight}};
            _audioPlayHolder.frame = _videoView.bounds;
            _segmentView.frame = (CGRect){{0, CGRectGetMaxY(_videoView.frame)}, {_videoView.bounds.size.width, self.segHeight}};
            
            hasOrientation = NO;
            self.segmentView.hidden = NO;
            if(_currentSegmentItem.type == SegmentItmeType_live_doc){
                self.docView.hidden = NO;
            }else if(_currentSegmentItem.type == SegmentItmeType_live_doc){
                self.chatView.hidden = NO;
            }
        }];
    }
}

//文档旋转屏
- (void)rotationdocView:(UIGestureRecognizer *)gestureRecognizer {
    //强制旋转
    if (!hasOrientation) {
        [UIView animateWithDuration:0.5 animations:^{
            self.superview.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.superview.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            _docView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            
            hasOrientation = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            _docView.zoomEnabled = YES;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.superview.transform = CGAffineTransformInvert(CGAffineTransformMakeRotation(0));
            self.superview.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            _docView.frame = docViewRect;
            
            hasOrientation = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            _docView.zoomEnabled = NO;
        }];
    }
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
    }
    _playerManager.delegate = self;
    GSPJoinParam *joinParam = [_liveParam gspJoinParam];
    joinParam.oldVersion = NO;
    
    [_playerManager joinWithParam:joinParam];
}

#pragma mark - GHToolViewDelegate 
- (void)sendMessage:(NSString *)content
{
    GSPChatMessage *message = [[GSPChatMessage alloc] init];
    message.text = content;
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
        case GSPJoinResultCreateRtmpPlayerFailed:
            result = NSLocalizedString(@"创建直播实例失败", @"");
            break;
        case GSPJoinResultJoinReturnFailed:
            result = NSLocalizedString(@"调用加入直播失败", @"");
            break;
        case GSPJoinResultNetworkError:
            result = NSLocalizedString(@"网络错误", @"");
            break;
        case GSPJoinResultUnknowError:
            result = NSLocalizedString(@"未知错误", @"");
            break;
        case GSPJoinResultParamsError:
            result = NSLocalizedString(@"参数错误", @"");
            break;
        case GSPJoinResultOK:
            result = @"加入成功";
            break;
        case GSPJoinResultCONNECT_FAILED:
            result = NSLocalizedString(@"连接失败", @"");
            break;
        case GSPJoinResultTimeout:
            result = NSLocalizedString(@"连接超时", @"");
            break;
        case GSPJoinResultRTMP_FAILED:
            result = NSLocalizedString(@"链接媒体服务器失败", @"");
            break;
        case GSPJoinResultTOO_EARLY:
            result = NSLocalizedString(@"直播尚未开始", @"");
            break;
        case GSPJoinResultLICENSE:
            result = NSLocalizedString(@"人数已满", @"");
            break;
        default:
            result = NSLocalizedString(@"错误", @"");
            break;
    }
    
    UIAlertView *alertView;
    if ([result isEqualToString:@"加入成功"]) {
        
    } else {
        alertView = [[UIAlertView alloc] initWithTitle:result message:NSLocalizedString(@"请退出重试", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"知道了", @"") otherButtonTitles:nil];
        [self addSubview:alertView];
        [alertView show];
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
        [_videoView addSubview:_audioPlayHolder];
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
    if (_docView.hidden && !hasOrientation && _currentSegmentItem.type == SegmentItmeType_live_doc) {
        _docView.hidden=NO;
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
