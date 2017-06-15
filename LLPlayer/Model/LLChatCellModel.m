//
//  LLChatCellModel.m
//  xdfapp
//
//  Created by tony on 2017/6/12.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "PlayerSDK/PlayerSDK.h"
#import "LLChatCellModel.h"

#import "LLColorTool.h"
#import "NSAttributedString+Attributes.h"
#import "MarkupParser.h"
#import "OHAttributedLabel.h"


@interface LLChatCellModel()
@end
@implementation LLChatCellModel

- (void)layoutCellFrame
{
    self.cellHeight = [self getHeightWithMessage:self.cellMessage];
}

- (CGFloat)getHeightWithMessage:(GSPChatMessage *)message {
    
    CGFloat marginX = self.marginX;
    CGFloat marginY = self.marginY;
    
    //图标
    _iconFrame = (CGRect){{marginX, marginY}, {40.0, 40.0}};
    //标题
    _titleFrame = (CGRect){{CGRectGetMaxX(_iconFrame) + 5.0, marginY},{_cellWidth - (CGRectGetMaxX(_iconFrame) + 20.0), self.titleFont.lineHeight + 10.0}};
    
    //内容布局
    CGFloat contentX = CGRectGetMinX(_titleFrame);
    CGFloat chatBackImageX = 0;
    
    CGFloat contentY = CGRectGetMaxY(_titleFrame);
    CGFloat chatBackImageY = 0;
    
    CGFloat contentWidth = _cellWidth - (CGRectGetMaxX(_iconFrame) + 20.0);
    
    if(_chatBackImage.length){//有聊天背景图
        chatBackImageX = CGRectGetMaxX(_iconFrame);
        contentX = chatBackImageX + self.marginX;
        
        contentWidth = contentWidth - self.marginX - contentX;
        
        chatBackImageY = contentY;
        contentY = contentY + 8.0;
    }
    
    _contentFrame = (CGRect){{contentX, contentY},{contentWidth, 0}};
    
    _titleAttString = [[NSAttributedString alloc] initWithString:message.senderName attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0], NSForegroundColorAttributeName:[LLColorTool colorWithHexString:@"#222222"]}];
    
    OHAttributedLabel *contentLabel  = [[OHAttributedLabel alloc]initWithFrame:_contentFrame];
    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    contentLabel.linkColor = nil;//链接的颜色，默认蓝色
    contentLabel.underlineLinks = NO;//不显示链接下面的线
    
    NSString *color;
    if (message.chatType == GSPChatTypeSystem) {
        color = @"#222222";
    }else if (message.chatType == GSPChatTypePrivate) {
        color = @"#222222";
    } else {
        if (message.role == 7 | message.role == 3) {
            color = @"#222222";
        } else {
            color = @"#222222";
        }
    }
    
    NSString *text = [self transformString:message.richText];
    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"&lt;br&gt;"];
    text = [text stringByReplacingOccurrencesOfString:@"<BR>" withString:@"\n"];//PC换行
    text = [text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];//安卓换行
    //text = [NSString stringWithFormat:@"<font color='%@'>%@\n<font color='%@' face='Palatino-Roman'>%@",color,message.senderName,color,text];
    text = [NSString stringWithFormat:@"<font color='%@' face='Palatino-Roman'>%@",color,text];
    
    MarkupParser* p = [[MarkupParser alloc] init];
    _contentAttString = [p attrStringFromMarkup: text];
    
    //行间距样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    //[_contentAttString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, _contentAttString.length)];
    
    [_contentAttString setFont:self.contentFont];
    _images = p.images;
    
    [contentLabel setAttString:_contentAttString withImages:_images];
    
    //计算高度
    _contentFrame.size = [contentLabel sizeThatFits:CGSizeMake(_contentFrame.size.width, CGFLOAT_MAX)];
    contentLabel.frame = _contentFrame;
    _contentFrame = contentLabel.frame;
    
    if(_chatBackImage.length){
        CGFloat backImageWidth = MAX(_contentFrame.size.width + self.marginX*2, 160.0);
        _chatBackImageFrame = (CGRect){{chatBackImageX, chatBackImageY}, {backImageWidth, _contentFrame.size.height + 16.0}};
    }
    
    return (MAX(CGRectGetMaxY(_contentFrame), CGRectGetMaxY(_chatBackImageFrame)) + 6.0);
}

- (NSString *)transformString:(NSString *)originalStr
{
    @synchronized (self) {
        //匹配表情，将表情转化为html格式
        NSString *text = originalStr;
        
        NSRegularExpression* preRegex = [[NSRegularExpression alloc]
                                         initWithPattern:@"<IMG.+?src=\"(.*?)\".*?>"
                                         options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                         error:nil]; //2
        NSArray* matches = [preRegex matchesInString:text options:0
                                               range:NSMakeRange(0, [text length])];
        
        int offset = 0;
        
        for (NSTextCheckingResult *match in matches) {
            
            NSRange imgMatchRange = [match rangeAtIndex:0];
            imgMatchRange.location += offset;
            
            NSString *imgMatchString = [text substringWithRange:imgMatchRange];
            
            NSRange srcMatchRange = [match rangeAtIndex:1];
            srcMatchRange.location += offset;
            
            NSString *srcMatchString = [text substringWithRange:srcMatchRange];
            
            NSString *i_transCharacter = [self.key2fileDic objectForKey:srcMatchString];
            //[NSString stringWithFormat:@"PlayerSDK.bundle/%@",i_transCharacter]
            if (i_transCharacter) {
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f'>", i_transCharacter,self.contentFont.lineHeight,self.contentFont.lineHeight];
                text = [text stringByReplacingCharactersInRange:NSMakeRange(imgMatchRange.location, [imgMatchString length]) withString:imageHtml];
                offset += (imageHtml.length - imgMatchString.length);
            }
            
        }
        
        return text;
    }
    
}

- (CGFloat)marginY
{
    if(_marginY == 0){
        _marginY = 13.0;
    }
    return _marginY;
}

- (CGFloat)marginX
{
    if(_marginX == 0){
        _marginX = 15.0;
    }
    return _marginX;
}

- (UIFont *)titleFont
{
    if(!_titleFont){
        _titleFont = [UIFont systemFontOfSize:12.0];
    }
    return _titleFont;
}

- (UIFont *)contentFont
{
    if(!_contentFont){
        _contentFont = [UIFont systemFontOfSize:14.0];
    }
    return _contentFont;
}

@end
