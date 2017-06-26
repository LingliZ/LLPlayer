//
//  LLV_XMLParse.h
//  LLVNetWorkKit
//
//  Created by 吴海超 on 15/4/28.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//
/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windLLV/article/category/3117381
 */
#import <Foundation/Foundation.h>

#define  kLLVCanFilterString (@":")                 //可过滤的字符串

typedef enum:NSInteger {
    LLV_XMLParserOptionsProcessNamespaces           = 1 << 0, // 指定是否接对象名称空间和元素的限定名称
    LLV_XMLParserOptionsReportNamespacePrefixes     = 1 << 1, // 指定是否接对象名称空间声明的范围
    LLV_XMLParserOptionsResolveExternalEntities     = 1 << 2, // 指定的接收对象声明是否外部实体
}LLV_XMLParserOptions;

/**
 * 说明 LLV_XMLParser xml解析器自动把xml字符串解析为字典对象(和json字符串解析为字典一样无任何多余key)
 */

@interface LLV_XMLParser : NSObject

/**
 * 说明: xml数据对象解析为字典
 * @param: data xml数据对象
 */

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data;

/**
 * 说明: xml数据对象解析为字典
 * @param: data xml数据对象
 */

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string;

/**
 * 说明: xml数据对象解析为字典
 * @param: data xml数据对象
 * @param: options xml解析类型
 */

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data options:(LLV_XMLParserOptions)options;

/**
 * 说明: xml字符串对象解析为字典
 * @param: string xml字符串对象
 * @param: options xml解析类型
 */
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string options:(LLV_XMLParserOptions)options;

/**
 * 说明: xml数据对象解析为字典
 * @param: data xml数据对象
 * @param: filterString xml解析过滤字符串
 */

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data filterString:(NSString *)filterString;

/**
 * 说明: xml字符串对象解析为字典
 * @param: string xml字符串对象
 * @param: filterString xml解析过滤字符串
 */

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string filterString:(NSString *)filterString;

/**
 * 说明: xml数据对象解析为字典
 * @param: data xml数据对象
 * @param: filterString xml解析过滤字符串
 * @param: options xml解析类型
 */

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data filterString:(NSString *)filterString options:(LLV_XMLParserOptions)options;

/**
 * 说明: xml字符串对象解析为字典
 * @param: string xml字符串对象
 * @param: filterString xml解析过滤字符串
 * @param: options xml解析类型
 */

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string filterString:(NSString *)filterString options:(LLV_XMLParserOptions)options;
@end
