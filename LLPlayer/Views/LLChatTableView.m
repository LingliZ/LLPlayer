//
//  LLChatTableView.m
//  xdfapp
//
//  Created by tony on 2017/6/12.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLChatCellModel.h"

#import <PlayerSDK/PlayerSDK.h>
#import "LLPublicTool.h"

#import "LLChatCell.h"
#import "LLChatTableView.h"

@interface LLChatTableView ()<UITableViewDelegate,UITableViewDataSource> {
    BOOL isScroll;
    NSMutableArray *dataArrar;
}

@property (retain,  nonatomic) GSPChatMessage *chatMessage;
@property (retain,  nonatomic) NSMutableArray *messageArr;
@property (nonatomic, strong) NSDictionary *key2fileDic;
@property (nonatomic, strong) NSDictionary *text2fileDic;
@end

@implementation LLChatTableView
static LLChatTableView *chatTable = nil;

- (void)dealloc {
    
}

- (NSDictionary*)text2fileDic
{
    if (!_text2fileDic) {
        NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"PlayerSDK" ofType:@"bundle"]];
        _text2fileDic = [NSDictionary dictionaryWithContentsOfFile:[resourceBundle pathForResource:@"text2file" ofType:@"plist"]];
    }
    return _text2fileDic;
}

- (NSDictionary*)text2keyDic
{
    if (!_text2keyDic) {
        NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"PlayerSDK" ofType:@"bundle"]];
        _text2keyDic = [NSDictionary dictionaryWithContentsOfFile:[resourceBundle pathForResource:@"text2key" ofType:@"plist"]];
    }
    return _text2keyDic;
}

- (NSDictionary *)key2fileDic {
    if (!_key2fileDic) {
        NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"PlayerSDK" ofType:@"bundle"]];
        _key2fileDic = [NSDictionary dictionaryWithContentsOfFile:[resourceBundle pathForResource:@"key2file" ofType:@"plist"]];
    }
    return _key2fileDic;
}

+ (instancetype)getChatView {
    if (chatTable == nil) {
        chatTable = [[self alloc]init];
    }
    return chatTable;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _messageArr = [[NSMutableArray alloc]init];
        dataArrar = [[NSMutableArray alloc]init];
        self.userInteractionEnabled = YES;
        [self setupTableView];
    }
    chatTable = self;
    return self;
}
 
- (void)setupTableView {

    //聊天table
    _chatTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    _chatTableView.backgroundColor = [UIColor clearColor];
    [self addSubview:_chatTableView];
    
    _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _chatTableView.showsVerticalScrollIndicator = NO;
    _chatTableView.estimatedRowHeight = 100;//很重要保障滑动流畅性
    _chatTableView.allowsSelection = NO;
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
}

- (NSString*)chatString:(NSString*)originalStr
{
    NSRegularExpression* preRegex = [[NSRegularExpression alloc]
                                     initWithPattern:@"【([\u4E00-\u9FFF]*?)】"
                                     options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                     error:nil]; //2
    NSArray* matches = [preRegex matchesInString:originalStr options:0
                                           range:NSMakeRange(0, [originalStr length])];
    
    int offset = 0;
    
    for (NSTextCheckingResult *match in matches) {
        //NSRange srcMatchRange = [match range];
        NSRange emotionRange = [match rangeAtIndex:0];
        emotionRange.location += offset;
        
        NSString *emotionString = [originalStr substringWithRange:emotionRange];
        
        NSString *i_transCharacter = [self.text2keyDic objectForKey:emotionString];
        
        if (i_transCharacter) {
            NSString *imageHtml = nil;
            {
                imageHtml = [NSString stringWithFormat:@"<IMG src=\"%@\" custom=\"false\">", i_transCharacter];
            }
            originalStr = [originalStr stringByReplacingCharactersInRange:NSMakeRange(emotionRange.location, [emotionString length]) withString:imageHtml];
            offset += (imageHtml.length - emotionString.length);
        }
    }
    return originalStr;
}

# pragma mark ------------接收到消息的处理 
- (void)reloadWithMessage:(GSPChatMessage *)message{
    //转义 < >
    message.text = [message.text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br>"];
    
    message.richText = [message.text stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    message.richText = [message.richText stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    
    message.richText = [self chatString:message.richText];
    
    message.richText =[message.richText stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<BR>"];
    message.richText = [message.richText stringByReplacingOccurrencesOfString:@"\n" withString:@"<BR>"];
    
        @synchronized (self) {
            
            _chatMessage = message;
            
            if (message.chatType == GSPChatTypePublic) {
                if ( _userInfo.userID == message.senderUserID) {
                    message.senderName = NSLocalizedString(@"我",@"");
                }else {
                    message.senderName = [LLPublicTool getFinalTitleWithTitle:message.senderName andSort:LLTitleSort_nickNameTitle];
                }
            }else if (message.chatType == GSPChatTypeSystem){
                
            }else{
                message.senderName = [NSString stringWithFormat:@"%@ 对 %@ 说",[LLPublicTool getFinalTitleWithTitle:message.senderName andSort:LLTitleSort_nickNameTitle],NSLocalizedString(@"我",@"")];
            }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_messageArr.count>=200) {
                [_messageArr removeObjectAtIndex:0];
            }

            LLChatCellModel *model = [LLChatCellModel new];
            model.cellWidth = self.bounds.size.width;
            model.cellMessage = message;
            model.key2fileDic = self.key2fileDic;
            if(message.role == 7){//主讲人
                model.chatBackImage = @"ll_chat_ialog3";
                model.chatRole = 3;
            }else{//其他人
                if ( _userInfo.userID == message.senderUserID) {//用户自己
                    model.chatBackImage = @"ll_chat_ialog2";
                    model.chatRole = 2;
                }else {
                    model.chatBackImage = @"ll_chat_ialog1";
                    model.chatRole = 1;
                }
            }
            [model layoutCellFrame];
            
            [_messageArr addObject:model];
            
        if (isScroll) {
                
        }else {
            //把数据源数组清空，再添加新的数据
            [dataArrar removeAllObjects];
            [dataArrar addObjectsFromArray:_messageArr];
            [_chatTableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:dataArrar.count - 1 inSection:0];
        [_chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                
            }
        });
    }
}

- (void)finalTableHeight {
    __block typeof(self)  weakself = self;

    if (dataArrar.count>0) {
        @synchronized (self) {
            __block    float tableHeight = 0;
            [dataArrar enumerateObjectsUsingBlock:^(LLChatCellModel *model, NSUInteger idx, BOOL *stop) {
                tableHeight += model.cellHeight;
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (tableHeight < weakself.frame.size.height) {
                    _chatTableView.frame = CGRectMake(0, 0, _chatTableView.frame.size.width, tableHeight);
                }else {
                    _chatTableView.frame = CGRectMake(0, 0, weakself.frame.size.width, weakself.frame.size.height);
                }
            });
        }
    }else {
        return;
    }
}

# pragma mark ------------Table Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //[self finalTableHeight];

    return dataArrar.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    
    LLChatCell *chatCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!chatCell) {
        chatCell = [[LLChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        chatCell.key2fileDic = self.key2fileDic;
        
        chatCell.dic3 = self.text2fileDic;
    }

    LLChatCellModel *model = dataArrar[indexPath.row];
    model.cellWidth = self.bounds.size.width;
    chatCell.model = model;
 
    return chatCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0){
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LLChatCellModel *model = dataArrar[indexPath.row];
    return model.cellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _chatTableView) {
        
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == _chatTableView) {
        isScroll = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _chatTableView) {
        if (scrollView.contentSize.height-20 <=scrollView.contentOffset.y+scrollView.frame.size.height) {
            isScroll = NO;
            return;
        }
    }
}

@end
