//
//  LLV_DownloadSessionTask.h
//  LLVNetWorkKit
//
//  Created by 吴海超 on 15/12/7.
//  Copyright © 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windLLV/article/category/3117381
 */

#import "LLV_DownloadOperation.h"

/**
 * 说明: LLV_DownloadSessionTask  单个后台下载任务类
 */

@interface LLV_DownloadSessionTask : LLV_DownloadOperation

/**
 * 当前后台下载任务对象
 */
@property (nonatomic , strong)NSURLSessionDownloadTask * downloadTask;

/**
 * 函数说明: 取消当前下载任务
 * @param: isDelete 取消下载任务的同时是否删除下载缓存的文件
 */

- (void)cancelDownloadTaskAndDeleteFile:(BOOL)isDelete;

/**
 * 函数说明: 处理下载应答
 * @param: response 下载应答对象
 */

- (void)handleResponse:(NSURLResponse *)response;
@end
