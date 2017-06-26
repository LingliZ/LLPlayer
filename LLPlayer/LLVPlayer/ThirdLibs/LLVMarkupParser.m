//
//  MarkupParser.m
//  xdfapp
//
//  Created by tony on 2017/6/15.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import "LLVMarkupParser.h"

static void deallocCallback_ll( void* ref ){
    //(__bridge id)ref;
}

static CGFloat ascentCallback_ll( void *ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback_ll( void *ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"descent"] floatValue];
}

static CGFloat widthCallback_ll( void* ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

@interface LLVMarkupParser()
@property (strong, nonatomic) NSDictionary *ref;
@end

@implementation LLVMarkupParser
@synthesize font, color, strokeColor, strokeWidth;
@synthesize images;

-(id)init
{
    self = [super init];
    if (self) {
        self.font = @"Arial";
        self.color = [UIColor blackColor];
        self.strokeColor = [UIColor whiteColor];
        self.strokeWidth = 0.0;
        self.images = [NSMutableArray array];
    }
    return self;
}

-(NSAttributedString*)attrStringFromMarkup:(NSString*)markup
{
    NSMutableAttributedString* aString =
    [[NSMutableAttributedString alloc] initWithString:@""]; //1
    
    NSRegularExpression* regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"(.*?)(<[^>]+>|\\Z)"
                                  options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                  error:nil]; //2
    NSArray* chunks = [regex matchesInString:markup options:0
                                       range:NSMakeRange(0, [markup length])];
    for (NSTextCheckingResult* b in chunks) {
        NSArray* parts = [[markup substringWithRange:b.range]
                          componentsSeparatedByString:@"<"]; //1
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.font,
                                                 24.0f, NULL);
        
        //apply the current text style //2
        NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               (id)self.color.CGColor, kCTForegroundColorAttributeName,
                               (__bridge id)fontRef, kCTFontAttributeName,
                               (id)self.strokeColor.CGColor, (NSString *) kCTStrokeColorAttributeName,
                               (id)[NSNumber numberWithFloat: self.strokeWidth], (NSString *)kCTStrokeWidthAttributeName,
                               nil];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[parts objectAtIndex:0] attributes:attrs]];
        
        
        //handle new formatting tag //3
        if ([parts count]>1) {
            NSString* tag = (NSString*)[parts objectAtIndex:1];
            if ([tag hasPrefix:@"font"]) {
                //stroke color
                NSRegularExpression* scolorRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=strokeColor=[\'\"])\\w+" options:0 error:NULL];
                [scolorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    if ([[tag substringWithRange:match.range] isEqualToString:@"none"]) {
                        self.strokeWidth = 0.0;
                    } else {
                        self.strokeWidth = -2.0;
                        SEL colorSel = NSSelectorFromString([NSString stringWithFormat: @"%@Color", [tag substringWithRange:match.range]]);
                        self.strokeColor = [UIColor performSelector:colorSel];
                    }
                }];
                
                //color
                NSRegularExpression* colorRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=color=[\'\"])\\w+" options:0 error:NULL];
                [colorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    SEL colorSel = NSSelectorFromString([NSString stringWithFormat: @"%@Color", [tag substringWithRange:match.range]]);
                    self.color = [UIColor performSelector:colorSel];
                }];
                
                //face
                NSRegularExpression* faceRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=face=[\'\"])[^[\'\"]]+" options:0 error:NULL];
                [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    self.font = [tag substringWithRange:match.range];
                }];
            } //end of font parsing
            if ([tag hasPrefix:@"img"]) {
                
                __block NSNumber* width = [NSNumber numberWithInt:0];
                __block NSNumber* height = [NSNumber numberWithInt:0];
                __block NSString* fileName = @"";
                
                //width
                NSRegularExpression* widthRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=width=[\'\"])[^[\'\"]]+" options:0 error:NULL];
                [widthRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    width = [NSNumber numberWithInt: [[tag substringWithRange: match.range] intValue] ];
                }];
                
                //height
                NSRegularExpression* faceRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=height=[\'\"])[^[\'\"]]+" options:0 error:NULL];
                [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    height = [NSNumber numberWithInt: [[tag substringWithRange:match.range] intValue]];
                }];
                
                //image
                NSRegularExpression* srcRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=src=[\'\"])[^[\'\"]]+" options:0 error:NULL];
                [srcRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    fileName = [tag substringWithRange: match.range];
                }];
                
                self.ref = [NSDictionary dictionaryWithObjectsAndKeys:
                            width, @"width",
                            height, @"height",
                            fileName, @"fileName",
                            [NSNumber numberWithInteger: [aString length]], @"location",
                            nil];
                //add the image for drawing
                [self.images addObject:self.ref];
                
                //render empty space for drawing the image in the text //1
                CTRunDelegateCallbacks callbacks;
                callbacks.version = kCTRunDelegateVersion1;
                callbacks.getAscent = ascentCallback_ll;
                callbacks.getDescent = descentCallback_ll;
                callbacks.getWidth = widthCallback_ll;
                callbacks.dealloc = deallocCallback_ll;//释放
                
                //NSDictionary *imgDic = [NSDictionary dictionaryWithObjectsAndKeys:width, @"width",height, @"height",nil];
                //CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)(imgDic));
                CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)(self.ref));
                
                NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        //set the delegate
                                                        (__bridge id)delegate, (NSString*)kCTRunDelegateAttributeName,
                                                        nil];
                
                //add a space to the text so that it can call the delegate
                // 空格的属性（长和宽为将要绘制图片的长和宽,原先的" "改成"-"
                // 因为空格换行时会出现问题，造成连续打印表情显示成一行
                // 后续处理时我们需要将这块区域先clear掉，不然就会有字符
                // 目前没想到更好的方法，算是曲线救国的方式
                [aString appendAttributedString:[[NSAttributedString alloc] initWithString:@"-" attributes:attrDictionaryDelegate] ];
            }
        }
        CFRelease(fontRef);
    }
    
    
    return (NSAttributedString*)aString;
}
@end
