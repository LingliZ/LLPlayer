//
//  LLVInputToolView.m
//  LLVEmojiKeyboard
//
//  Created by tony on 2017/6/19.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVInputToolView.h"
#import "LLVColorTool.h"

#define defaultHeight 50

@interface LLVInputToolView()<UITextViewDelegate> {
    CGRect initialFrame;
}

@property (nonatomic, strong) LLVEmojiCollectionView *emojiCollectionView;

@property (nonatomic, strong) NSDictionary *keyboadUserInfo;

@end

@implementation LLVInputToolView

#pragma mark -
#pragma mark Init Methods


- (id)initWithParentFrame:(CGRect)parentFrame
{
    float y = parentFrame.origin.y + parentFrame.size.height - defaultHeight;
   
    CGRect frame = CGRectMake(0,  y, parentFrame.size.width, defaultHeight);
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpWithParentView:frame emojiPlistFileName:nil inBundle:nil];
        
        self.inputTextView.delegate = self;
        
        [self addNotificationObserver];
    }
    return self;
}

- (id)initWithParentFrame:(CGRect)parentFrame emojiPlistFileName:(NSString *)fileName inBundle:(NSBundle *)bundle;
{
    float y = parentFrame.origin.y + parentFrame.size.height - defaultHeight;
    initialFrame = CGRectMake(0, y, parentFrame.size.width, defaultHeight);
    self = [super initWithFrame:initialFrame];
    if (self) {
        
        [self setUpWithParentView:initialFrame emojiPlistFileName:fileName inBundle:bundle];
        
        self.inputTextView.delegate = self;
        
        [self addNotificationObserver];
    }
    return self;
}

- (void)setUpWithParentView:(CGRect)frame emojiPlistFileName:(NSString*)fileName inBundle:bundle
{
    _inputTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    _inputTextView.layer.borderColor = [LLVColorTool colorWithHexString:@"#d1d1d1"].CGColor;
    _inputTextView.layer.borderWidth = 1.0;
    _inputTextView.layer.masksToBounds = YES;
    _inputTextView.font = [UIFont systemFontOfSize:14.f];
    _inputTextView.textColor = [LLVColorTool colorWithHexString:@"#999999"];
    [self addSubview:_inputTextView];

    //可以约束光标位置
    self.inputTextView.textContainerInset = UIEdgeInsetsMake(8, 5, 0, 0);
    [self.inputTextView setReturnKeyType:UIReturnKeyDefault];

    self.inputTextView.translatesAutoresizingMaskIntoConstraints = NO;

    if (fileName) {
        self.emojiCollectionView = [[LLVEmojiCollectionView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, frame.size.width, 150) emijiPlistFileName:fileName inBundle:bundle];

        __weak __block LLVInputToolView *copy_self = self;
        
        //获取图片并显示
        [self.emojiCollectionView setEmojiCollectionViewBlock:^(UIImage *emojiImage, NSString *emojiText)
        {
             [copy_self.inputTextView insertText:emojiText];
         }];
        
        self.emojiButton = [[UIButton alloc]initWithFrame:CGRectZero];
        [self addSubview:self.emojiButton];
        [self.emojiButton addTarget:self action:@selector(switchInputView:) forControlEvents:UIControlEventTouchUpInside];
        [self.emojiButton setImage:[UIImage imageNamed:@"ll_keyboard_pure_emj"] forState:UIControlStateNormal];
    }
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton setBackgroundColor:[LLVColorTool colorWithHexString:@"#00c498"]];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    _sendButton.enabled = NO;
    [self addSubview:_sendButton];
    [_sendButton addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //开发布局
    CGSize sendButtonSize = (CGSize){65.0, 35.0};
    CGFloat inputTextH = sendButtonSize.height;
    CGFloat marginX = 15.0;
    
    _sendButton.frame = (CGRect){{self.bounds.size.width - marginX - sendButtonSize.width, (self.bounds.size.height - sendButtonSize.height)/2.0}, sendButtonSize};
    _sendButton.layer.cornerRadius = sendButtonSize.height/2.0;
    
    if(_emojiButton){
        _emojiButton.frame = (CGRect){CGPointZero, { _emojiButton.currentImage.size.width + marginX*2 ,self.bounds.size.height}};
        _inputTextView.frame = (CGRect){{CGRectGetMaxX(_emojiButton.frame), (self.bounds.size.height - sendButtonSize.height)/2.0},{CGRectGetMinX(_sendButton.frame) - CGRectGetMaxX(_emojiButton.frame) - marginX, inputTextH}};
    }else{
        _inputTextView.frame = (CGRect){{marginX, (self.bounds.size.height - sendButtonSize.height)/2.0},{CGRectGetMinX(_sendButton.frame) - marginX*2, inputTextH}};
    }
    _inputTextView.layer.cornerRadius = inputTextH/2.0;
}

- (void)endEditting
{
    [self.inputTextView resignFirstResponder];
}

- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)keyNotification:(NSNotification*)notification
{
    self.keyboadUserInfo = notification.userInfo;
    CGRect rect = [notification.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
       
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]floatValue] animations: ^{
        
        [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] doubleValue]];
        
        CGRect frame = self.frame;
        
        float y = rect.origin.y - frame.size.height;
     
        frame.origin.y = y;
        
        self.frame = frame;
        
        
    }];
}

#pragma mark - 
#pragma mark Actions

- (void)switchInputView:(id)sender
{
    if ([self.inputTextView.inputView isEqual:self.emojiCollectionView]) {
        self.inputTextView.inputView = nil;
        [self.emojiButton setImage:[UIImage imageNamed:@"ll_keyboard_pure_emj"] forState:UIControlStateNormal];
        [self.inputTextView reloadInputViews];
    }else{
        self.inputTextView.inputView = self.emojiCollectionView;
        [self.emojiButton setImage:[UIImage imageNamed:@"ll_keyboard_pure_newKb"] forState:UIControlStateNormal];
        [self.inputTextView resignFirstResponder];
        [self.inputTextView reloadInputViews];
    }
    
//    if ([self.inputTextView isFirstResponder]) {
//        [self.inputTextView resignFirstResponder];
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.3f];
//    }
//    else
//    {
//        [self.inputTextView becomeFirstResponder];
//    
//    }
}

- (void)delayMethod
{
    [self.inputTextView becomeFirstResponder];

}

#pragma mark -
#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
//    _inputTextView.attributedText = [_inputTextView.text ]
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0) {
//        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendButton.enabled = YES;
    }else {
//        [_sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _sendButton.enabled = NO;
    }
    

    // Resize ToolView according to content size of textview
//    CGSize contentSize = self.inputTextView.contentSize;
//
//    float height = contentSize.height + 16;
//    if (height <= 150) {
//        CGRect frame = self.frame;
//        frame.origin.y = frame.origin.y - (height - frame.size.height);
//        frame.size.height = height;
//        self.frame = frame;
//    }
}

//发送信息
- (void)sendClick:(UIButton *)sender {
    
    if (!_inputTextView.text || [[_inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"消息为空",@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"我知道了",@"") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(sendMessage:)]) {
        [self.delegate sendMessage:self.inputTextView.text];
    }
    self.inputTextView.text = @"";
    _sendButton.enabled = NO;
    [self.inputTextView  resignFirstResponder];
}

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    self.emojiCollectionView.backgroundColor = backgroundColor;
}

#pragma mark -
#pragma mark System Default Code

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (void)dealloc
{
    [self removeNotificationObserver];
}
@end
