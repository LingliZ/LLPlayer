//
//  LLV_DownloadSessionTask.m
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

#import "LLV_DownloadSessionTask.h"

@implementation LLV_DownloadSessionTask

- (void)cancelDownloadTaskAndDeleteFile:(BOOL)isDelete {
    if (isDelete) {
        [_downloadTask cancel];
    }
}

- (void)handleResponse:(NSURLResponse *)response {
    [self connection:nil didReceiveResponse:response];
}

@end
