//
//  LLVideoHeader.h
//  xdfapp
//
//  Created by tony on 2017/6/8.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#ifndef LLVideoHeader_h
#define LLVideoHeader_h

#define IS_IPAD_LL (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE_LL (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA_LL ([[UIScreen mainScreen] scale] >= 2.0)
#define SCREEN_WIDTH_LL ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT_LL ([UIScreen mainScreen].bounds.size.height)

//是否为4inch及以上
#define iPhone5Later_LL (SCREEN_WIDTH_LL >= 568 || SCREEN_HEIGHT_LL >= 568)
#define SCREEN_MAX_LENGTH_LL (MAX(SCREEN_WIDTH_LL, SCREEN_HEIGHT_LL))
#define SCREEN_MIN_LENGTH_LL (MIN(SCREEN_WIDTH_LL, SCREEN_HEIGHT_LL))

#define IS_IPHONE_4_OR_LESS_LL (IS_IPHONE_LL && SCREEN_MAX_LENGTH_LL < 568.0)
#define IS_IPHONE_5 (IS_IPHONE_LL && SCREEN_MAX_LENGTH_LL == 568.0)
#define IS_IPHONE_5_OR_LESS_LL (IS_IPHONE_LL && SCREEN_MAX_LENGTH_LL < 568.0)
#define IS_IPHONE_6 (IS_IPHONE_LL && SCREEN_MAX_LENGTH_LL == 667.0)
#define IS_IPHONE_6_OR_LESS_LL (IS_IPHONE_LL && SCREEN_MAX_LENGTH_LL < 667.0)
#define IS_IPHONE_6_OR_More_LL (IS_IPHONE_LL && SCREEN_MAX_LENGTH_LL >= 667.0)
#define IS_IPHONE_6P_LL (IS_IPHONE_LL && SCREEN_MAX_LENGTH_LL == 736.0)
#define IS_IPHONE_6P_OR_More_LL (IS_IPHONE && SCREEN_MAX_LENGTH_LL >= 736.0)

#endif /* LLVideoHeader_h */
