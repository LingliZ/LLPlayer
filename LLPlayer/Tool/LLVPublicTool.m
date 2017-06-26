//
//  PublicTool.m
//  xdfapp
//
//  Created by tony on 2017/6/13.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#define CELLHeihgt 56

#import "PlayerSDK.h"
#import "LLVPublicTool.h"

@interface LLVPublicTool() {
    
}

@end
@implementation LLVPublicTool
static UIScrollView *BGscroll;
//网络弹出框的背景
static UIView *view;
static UIButton *currentBtn;
static NSMutableArray *titleArr;

//获取最终显示的title
+ (NSString *)getFinalTitleWithTitle:(NSString *)title andSort:(LLTitleSort)sort{
    //    标题
    NSString *suffix = @"";
    NSString *current = title;
    NSInteger length = [self textLength:current];
    
    NSInteger purposLength;
    if (sort == LLTitleSort_liveTitle) {
        purposLength = 20;
    }else {
        purposLength = 24;
    }

    if (length<=purposLength) {
        
    }else {
        while (length >purposLength-2) {
            current = [current substringToIndex:current.length-1];
            length = [self textLength:current];
            
            suffix = @"...";
        }
    }
   
    NSString *showTitle = [NSString stringWithFormat:@"%@%@",current,suffix];

    return showTitle;
}

//获取字符串的长度
+ (NSUInteger)textLength:(NSString *) text{

    NSUInteger asciiLength = 0;

    for (NSUInteger i = 0; i < text.length; i++) {
        //循环取出text里面的单个字符
        unichar uc = [text characterAtIndex: i];
        //C语言isascii()函数：判断字符是否为ASCII码字符
        asciiLength += isascii(uc) ? 1 : 2;
        
    }

    NSUInteger unicodeLength = asciiLength;

    return unicodeLength;
}

//获取资源中的图片
+ (UIImage *)imagesNamedFromCustomBundle:(NSString *)imgName

{
    
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"FastSDK.bundle/Images"];
    
    NSString *img_path = [bundlePath stringByAppendingPathComponent:imgName];
    return [UIImage imageWithContentsOfFile:img_path];
    
}

//⚠️获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

+ (UIImage*)getImageByRetina:(NSString*)imageName
{
    float nativeWidth=  MIN([[UIScreen mainScreen] nativeBounds].size.width,[[UIScreen mainScreen] nativeBounds].size.height);
    float screenWidth=   MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    float currentRatio=nativeWidth/screenWidth;
    if (currentRatio<2) {
        return   [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[imageName stringByAppendingString:@"@2x"]]];
    }else{
        return    [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName]];
    }
    return    [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName]];
}

+ (NSString *)formatVProgressTime:(int)msec {
    int hours = msec / 1000 / 60 / 60;
    int minutes = (msec / 1000 / 60) % 60;
    int seconds = (msec / 1000) % 60;
    
    if(hours == 0){
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }else{
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
}

+ (NSString *)changeCreatTimeWithLong:(long long)creatTime  Formatter:(NSString *)formatter
{
    // 把时间戳转化成时间
    NSTimeInterval interval = creatTime;//默认秒
    if(creatTime >= 9999999999 && creatTime <= 9999999999999){//毫秒
        interval= (creatTime / 1000);
    }else if(creatTime > 9999999999999){//微秒
        interval = (creatTime / 1000) / 1000;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
    [objDateformat setDateFormat:formatter];
    NSString * timeStr = [NSString stringWithFormat:@"%@",[objDateformat stringFromDate: date]];
    
    return timeStr;
}

+ (NSString *)formatDateReadable:(NSString *)dateStr
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 如果是真机调试，转换这种欧美时间，需要设置locale
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    // 设置日期格式（声明字符串里面每个数字和单词的含义）
    // E:星期几
    // M:月份
    // d:几号(这个月的第几天)
    // H:24小时制的小时
    // m:分钟
    // s:秒
    // y:年
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //_created_at = @"Tue Sep 30 17:06:25 +0600 2014";
    
    // 微博的创建日期
    NSDate *createDate = [fmt dateFromString:dateStr];
    if(createDate){
        // 当前时间
        NSDate *now = [NSDate date];
        
        // 日历对象（方便比较两个日期之间的差距）
        NSCalendar *calendar = [NSCalendar currentCalendar];
        // NSCalendarUnit枚举代表想获得哪些差值
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        // 计算两个日期之间的差值
        NSDateComponents *cmps = [calendar components:unit fromDate:createDate toDate:now options:0];
        
        if ([LLVPublicTool isThisYear:createDate]) { // 今年
            if ([LLVPublicTool isYesterday:createDate]) { // 昨天
                fmt.dateFormat = [NSString stringWithFormat:@"%@ HH:mm", @"昨天"];
                return [fmt stringFromDate:createDate];
            } else if ([LLVPublicTool isToday:createDate]) { // 今天
                if (cmps.hour >= 1) {
                    return [NSString stringWithFormat:@"%d%@", (int)cmps.hour, @"小时前"];
                } else if (cmps.minute >= 1) {
                    return [NSString stringWithFormat:@"%d%@", (int)cmps.minute, @"分钟前"];
                } else {
                    return @"刚刚";
                }
            } else { // 今年的其他日子
                fmt.dateFormat = @"MM-dd HH:mm";
                return [fmt stringFromDate:createDate];
            }
        } else { // 非今年
            fmt.dateFormat = @"yyyy-MM-dd HH:mm";
            return [fmt stringFromDate:createDate];
        }
    }else{
        return dateStr;
    }
}

/**
 *  是否为今年
 */
+ (BOOL)isThisYear:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    
    return nowCmps.year == selfCmps.year;
}

/**
 *  是否为今天
 */
+ (BOOL)isToday:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    return
    (selfCmps.year == nowCmps.year) &&
    (selfCmps.month == nowCmps.month) &&
    (selfCmps.day == nowCmps.day);
}

/**
 *  是否为昨天
 */
+ (BOOL)isYesterday:(NSDate *)date
{
    // 2014-05-01
    NSDate *nowDate = [LLVPublicTool dateWithYMD:[NSDate date]];
    
    // 2014-04-30
    NSDate *selfDate = [LLVPublicTool dateWithYMD:date];
    
    // 获得nowDate和selfDate的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day == 1;
}

+ (NSDate *)dateWithYMD:(NSDate *)date
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:date];
    return [fmt dateFromString:selfStr];
}
@end
