//
//  MarkupParser.h
//  xdfapp
//
//  Created by tony on 2017/6/15.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface LLVMarkupParser : NSObject
{
    NSString *font;
    UIColor *color;
    UIColor *strokeColor;
    float stokeWidth;
    
    NSMutableArray *images;
}

@property (retain, nonatomic) NSString* font;
@property (retain, nonatomic) UIColor* color;
@property (retain, nonatomic) UIColor* strokeColor;
@property (assign, readwrite) float strokeWidth;

@property (retain, nonatomic) NSMutableArray* images;

-(NSMutableAttributedString*)attrStringFromMarkup:(NSString*)html;

@end
