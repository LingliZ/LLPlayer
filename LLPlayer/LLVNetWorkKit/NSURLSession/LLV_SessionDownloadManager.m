//
//  LLV_SessionDownloadOperation.m
//  LLVNetWorkKit
//
//  Created by 吴海超 on 15/11/30.
//  Copyright © 2015年 吴海超. All rights reserved.
//
/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windLLV/article/category/3117381
 */
#import "LLV_SessionDownloadManager.h"
#import "LLV_DownloadSessionTask.h"
#import "LLV_HttpManager.h"


@interface LLV_SessionDownloadManager () <NSURLSessionDataDelegate , NSURLSessionDelegate>{
    NSOperationQueue *  _asynQueue;
    NSURLSession     *  _downloadSession;
    NSMutableArray   *  _downloadTaskArr;
    NSMutableDictionary * _resumeDataDictionary;
    NSFileManager    *  _fileManager;
    NSMutableDictionary * _etagDictionary;
    NSString * _resumeDataPath;
}

@end

@implementation LLV_SessionDownloadManager

+ (instancetype)shared {
    static LLV_SessionDownloadManager * downloadManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [LLV_SessionDownloadManager new];
    });
    return downloadManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _asynQueue = [NSOperationQueue new];
        _asynQueue.maxConcurrentOperationCount = kLLVDefaultDownloadNumber;
        _downloadTaskArr = [NSMutableArray array];
        _resumeDataDictionary = [NSMutableDictionary dictionary];
        _fileManager = [NSFileManager defaultManager];
        _etagDictionary = [NSMutableDictionary dictionary];
        _resumeDataPath = [NSString stringWithFormat:@"%@/Library/Caches/LLVResumeDataCache/",NSHomeDirectory()];
        BOOL isDirectory = YES;
        if (![_fileManager fileExistsAtPath:_resumeDataPath isDirectory:&isDirectory]) {
            [_fileManager createDirectoryAtPath:_resumeDataPath
          withIntermediateDirectories:YES
                           attributes:@{NSFileProtectionKey:NSFileProtectionNone} error:nil];
        }
    }
    return self;
}

- (void)setBundleIdentifier:(nonnull NSString *)identifier {
    if (_downloadSession == nil) {
        _bundleIdentifier = nil;
        _bundleIdentifier = identifier.copy;
        NSURLSessionConfiguration * configuration;
        if ([NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]){
            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_bundleIdentifier];
        }else {
            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:_bundleIdentifier];
        }
        configuration.discretionary = YES;
        _downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_asynQueue];
        
    }
}

- (BOOL)waitingDownload {
    return _asynQueue.operations.count > kLLVDefaultDownloadNumber;
}

#pragma mark - 下载对外接口

- (nullable LLV_DownloadSessionTask *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                    delegate:(nullable id<LLV_DownloadDelegate>)delegate {
    return [self download:strUrl savePath:savePath saveFileName:nil delegate:delegate];
}


- (nullable LLV_DownloadSessionTask *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                saveFileName:(nullable NSString *)saveFileName
                                    delegate:(nullable id<LLV_DownloadDelegate>)delegate {
    LLV_DownloadSessionTask  * downloadTask = nil;
    NSString * fileName = nil;
    if (strUrl != nil && ![[LLV_HttpManager shared].failedUrls containsObject:strUrl]) {
        fileName = [[LLV_HttpManager shared] handleFileName:saveFileName url:strUrl];
        for (LLV_DownloadSessionTask * tempDownloadTask in _downloadTaskArr) {
            if ([fileName isEqualToString: tempDownloadTask.saveFileName]){
                __autoreleasing NSError * error = [[LLV_HttpManager shared] error:[NSString stringWithFormat:@"%@:已经在下载中",fileName]];
                if (delegate && [delegate respondsToSelector:@selector(LLVDownloadResponse:error:ok:)]) {
                    [delegate LLVDownloadResponse:tempDownloadTask error:error ok:NO];
                } else if (delegate && [delegate respondsToSelector:@selector(LLVDownloadDidFinished:data:error:success:)]) {
                    [delegate LLVDownloadDidFinished:tempDownloadTask data:nil error:error success:NO];
                }
                return tempDownloadTask;
            }
        }
        if([[LLV_HttpManager shared] createFileSavePath:savePath]) {
            
            downloadTask = [LLV_DownloadSessionTask new];
            downloadTask.requestType = LLVHttpRequestFileDownload;
            downloadTask.saveFileName = fileName;
            downloadTask.saveFilePath = savePath;
            downloadTask.delegate = delegate;
            downloadTask.strUrl = strUrl;
            downloadTask.delegate = delegate;
            [self startDownload:downloadTask];
        }
    }else {
        __autoreleasing NSError * error = [[LLV_HttpManager shared] error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
        if (delegate &&
            [delegate respondsToSelector:@selector(LLVDownloadDidFinished:data:error:success:)]) {
            [delegate LLVDownloadDidFinished:downloadTask data:nil error:error success:NO];
        }
    }
    return downloadTask;
    
}

- (nullable LLV_DownloadSessionTask *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                    response:(nullable LLVResponse)responseBlock
                                     process:(nullable LLVProgress)processBlock
                                 didFinished:(nullable LLVDidFinished)finishedBlock {
    return nil;
}

- (nullable LLV_DownloadSessionTask *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                saveFileName:(nullable NSString *)saveFileName
                                    response:(nullable LLVResponse) responseBlock
                                     process:(nullable LLVProgress) processBlock
                                 didFinished:(nullable LLVDidFinished) finishedBlock {
    LLV_DownloadSessionTask  * downloadTask = nil;
    NSString * fileName = nil;
    if (strUrl != nil && ![[LLV_HttpManager shared].failedUrls containsObject:strUrl]) {
        fileName = [[LLV_HttpManager shared] handleFileName:saveFileName url:strUrl];
        for (LLV_DownloadSessionTask * tempDownloadTask in _downloadTaskArr) {
            if ([fileName isEqualToString:tempDownloadTask.saveFileName]){
                __autoreleasing NSError * error = [[LLV_HttpManager shared] error:[NSString stringWithFormat:@"%@:已经在下载中",fileName]];
                if (responseBlock) {
                    responseBlock(tempDownloadTask, error, NO);
                } else if (finishedBlock) {
                    finishedBlock(tempDownloadTask ,nil, error, NO);
                }
                return tempDownloadTask;
            }
        }
        if([[LLV_HttpManager shared] createFileSavePath:savePath]) {
            downloadTask = [LLV_DownloadSessionTask new];
            downloadTask.requestType = LLVHttpRequestFileDownload;
            downloadTask.saveFileName = fileName;
            downloadTask.saveFilePath = savePath;
            downloadTask.progressBlock = processBlock;
            downloadTask.responseBlock = responseBlock;
            downloadTask.strUrl = strUrl;
            downloadTask.didFinishedBlock = ^(LLV_BaseOperation *operation,
                                                   NSData *data,
                                                   NSError *error,
                                                   BOOL isSuccess) {
                if (!isSuccess && error.code == 404) {
                    [[LLV_HttpManager shared].failedUrls addObject:strUrl];
                }
                if (finishedBlock) {
                    finishedBlock(operation , data , error , isSuccess);
                }
            };
            [self startDownload:downloadTask];
        }
    }else {
        __autoreleasing NSError * error = [[LLV_HttpManager shared] error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
        if (responseBlock) {
            responseBlock(downloadTask , error , NO);
        }else if (finishedBlock) {
            finishedBlock(downloadTask , nil , error , NO);
        }
    }
    return downloadTask;
}

#pragma mark - 私有方法

- (NSString *)getResumeDataFilePath:(NSString *)fileName {
    if (fileName && fileName.length > 0) {
        return [NSString stringWithFormat:@"%@%@",_resumeDataPath , fileName];
    }
    return nil;
}


- (void)startDownload:(LLV_DownloadSessionTask *)downloadTask {
    if (_downloadSession) {
        NSString * resumeDataFilePath = [self getResumeDataFilePath:downloadTask.saveFileName];
        if (resumeDataFilePath && [_fileManager fileExistsAtPath:resumeDataFilePath]) {
            NSData * resumeData = [NSData dataWithContentsOfFile:resumeDataFilePath];
            downloadTask.downloadTask = [_downloadSession downloadTaskWithResumeData:resumeData];
        }else {
            NSURL * url = [NSURL URLWithString:downloadTask.strUrl];
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
            downloadTask.downloadTask = [_downloadSession downloadTaskWithRequest:urlRequest];
        }
        [downloadTask startSpeedTimer];
        [downloadTask.downloadTask resume];
        [_downloadTaskArr addObject:downloadTask];
    }
}

- (void)cancelDownloadTask:(BOOL)isDelete task:(LLV_DownloadSessionTask *)task {
    if (!isDelete) {
        [task.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            // 存储恢复下载数据在didCompleteWithError处理
            NSLog(@"暂停下载");
        }];
    }else {
        [task cancelDownloadTaskAndDeleteFile:isDelete];
    }
}

#pragma mark - 下载过程对外接口

- (nullable LLV_DownloadSessionTask *)downloadOperationWithFileName:(nonnull NSString *)fileName {
    LLV_DownloadSessionTask * downloadTask = nil;
    for (LLV_DownloadSessionTask * tempDownloadTask in _downloadTaskArr) {
        if([tempDownloadTask.saveFileName isEqualToString:fileName]) {
            downloadTask = tempDownloadTask;
            break;
        }
    }
    return downloadTask;
}

- (void)cancelAllDownloadTaskAndDelFile:(BOOL)isDelete {
    for (LLV_DownloadSessionTask * task in _downloadTaskArr) {
        [self cancelDownloadTask:isDelete task:task];
    }
}

- (void)cancelDownloadWithDownloadUrl:(nonnull NSString *)strUrl deleteFile:(BOOL)isDelete {
    for(LLV_DownloadSessionTask * task in _downloadTaskArr){
        if ([task.strUrl isEqualToString:strUrl]) {
            [self cancelDownloadTask:isDelete task:task];
            break;
        }
    }
}

- (void)cancelDownloadWithFileName:(nonnull NSString *)fileName deleteFile:(BOOL)isDelete {
    for(LLV_DownloadSessionTask * task in _downloadTaskArr){
        if([task.saveFileName isEqualToString:fileName]){
            [self cancelDownloadTask:isDelete task:task];
            break;
        }
    }
}

- (LLV_DownloadSessionTask *)replaceCurrentDownloadOperationBlockResponse:(nullable LLVResponse)responseBlock
                                             process:(nullable LLVProgress)processBlock
                                         didFinished:(nullable LLVDidFinished)didFinishedBlock
                                            fileName:(nonnull NSString *)fileName {
    for (LLV_DownloadSessionTask * downloadTask in _downloadTaskArr) {
        if([downloadTask.saveFileName isEqualToString:fileName]){
            downloadTask.delegate = nil;
            downloadTask.progressBlock = processBlock;
            downloadTask.responseBlock = responseBlock;
            downloadTask.didFinishedBlock = didFinishedBlock;
            return downloadTask;
        }
    }
    return nil;
}

- (LLV_DownloadSessionTask *)replaceCurrentDownloadOperationDelegate:(nullable id<LLV_DownloadDelegate>)delegate
                                       fileName:(nonnull NSString *)fileName {
    for (LLV_DownloadSessionTask * downloadTask in _downloadTaskArr) {
        if([downloadTask.saveFileName isEqualToString:fileName]){
            downloadTask.progressBlock = nil;
            downloadTask.responseBlock = nil;
            downloadTask.didFinishedBlock = nil;
            downloadTask.delegate = delegate;
            return downloadTask;
        }
    }
    return nil;
}

- (LLV_DownloadSessionTask *)replaceAllDownloadOperationBlockResponse:(nullable LLVResponse)responseBlock
                                         process:(nullable LLVProgress)processBlock
                                     didFinished:(nullable LLVDidFinished)didFinishedBlock {
    if (_downloadTaskArr.count > 0) {
        for (LLV_DownloadSessionTask * downloadTask in _downloadTaskArr) {
            downloadTask.delegate = nil;
            downloadTask.progressBlock = processBlock;
            downloadTask.responseBlock = responseBlock;
            downloadTask.didFinishedBlock = didFinishedBlock;
        }
        return nil;
    }
    return nil;
}

- (LLV_DownloadSessionTask *)replaceAllDownloadOperationDelegate:(nullable id<LLV_DownloadDelegate>)delegate {
    if (_downloadTaskArr.count > 0) {
        for (LLV_DownloadSessionTask * downloadTask in _downloadTaskArr) {
            downloadTask.progressBlock = nil;
            downloadTask.responseBlock = nil;
            downloadTask.didFinishedBlock = nil;
            downloadTask.delegate = delegate;
        }
        return nil;
    }
    return nil;
}


- (BOOL)existDownloadOperationTaskWithFileName:(nonnull NSString *)fileName {
    BOOL  result = NO;
    for (LLV_DownloadSessionTask * downloadTask in _downloadTaskArr) {
        if([downloadTask.saveFileName isEqualToString:fileName]){
            result = YES;
            break;
        }
    }
    return result;
}

- (BOOL)existDownloadOperationTaskWithUrl:(nonnull NSString *)strUrl {
    BOOL  result = NO;
    for (LLV_DownloadSessionTask * downloadTask in _downloadTaskArr) {
        if([downloadTask.strUrl isEqualToString:strUrl]){
            result = YES;
            break;
        }
    }
    return result;
}


- (LLV_DownloadSessionTask *)getCurrentDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    LLV_DownloadSessionTask * LLV_downloadTask = nil;
    for (LLV_DownloadSessionTask * tempDownloadTask in _downloadTaskArr) {
        if ([tempDownloadTask.downloadTask isEqual:downloadTask]) {
            LLV_downloadTask = tempDownloadTask;
            break;
        }
    }
    return LLV_downloadTask;
}

- (void)removeDownloadTask:(LLV_DownloadSessionTask *)downloadTask {
    downloadTask.delegate = nil;
    downloadTask.downloadTask = nil;
    downloadTask.responseBlock = nil;
    downloadTask.didFinishedBlock = nil;
    downloadTask.progressBlock = nil;
    [_downloadTaskArr removeObject:downloadTask];
}


- (void)saveDownloadFile:(NSString *)path downloadTask:(LLV_DownloadSessionTask *)downloadTask {
    if (path) {
        if ([_fileManager fileExistsAtPath:downloadTask.saveFilePath isDirectory:NULL]) {
            NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:downloadTask.saveFilePath];
            [fileHandle seekToEndOfFile];
            NSData * data = [NSData dataWithContentsOfFile:path];
            if (data) {
                [fileHandle writeData:data];
                [fileHandle synchronizeFile];
                [fileHandle closeFile];
            }
        }else {
            [_fileManager moveItemAtPath:path toPath:downloadTask.saveFilePath error:NULL];
        }
    }
}

- (void)saveDidFinishDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                            toUrl:(NSURL *)location {
    LLV_DownloadSessionTask * LLV_downloadTask = [self getCurrentDownloadTask:downloadTask];
    if (LLV_downloadTask) {
        LLV_downloadTask.actualFileSizeLenght = downloadTask.countOfBytesExpectedToReceive;
        LLV_downloadTask.recvDataLenght = downloadTask.countOfBytesReceived;
        LLV_downloadTask.requestStatus = LLVHttpRequestFinished;
        [self saveDownloadFile:location.path downloadTask:LLV_downloadTask];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (LLV_downloadTask.delegate &&
                [LLV_downloadTask.delegate respondsToSelector:@selector(LLVDownloadProgress:recv:total:speed:)]) {
                [LLV_downloadTask.delegate LLVDownloadProgress:LLV_downloadTask
                                                          recv:downloadTask.countOfBytesReceived
                                                         total:downloadTask.countOfBytesExpectedToReceive
                                                         speed:LLV_downloadTask.networkSpeed];
                if ([LLV_downloadTask.delegate respondsToSelector:@selector(LLVDownloadDidFinished:data:error:success:)]) {
                    [LLV_downloadTask.delegate LLVDownloadDidFinished:LLV_downloadTask
                                                                 data:nil
                                                                error:nil
                                                              success:YES];
                }
            }else {
                if (LLV_downloadTask.progressBlock) {
                    LLV_downloadTask.progressBlock(LLV_downloadTask ,
                                                   downloadTask.countOfBytesReceived ,
                                                   downloadTask.countOfBytesExpectedToReceive ,
                                                   LLV_downloadTask.networkSpeed);
                }
                if (LLV_downloadTask.didFinishedBlock) {
                    LLV_downloadTask.didFinishedBlock(LLV_downloadTask , nil , nil , YES);
                }
            }
            [self removeDownloadTask:LLV_downloadTask];
        });
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    [self saveDidFinishDownloadTask:downloadTask toUrl:location];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    LLV_DownloadSessionTask * LLV_downloadTask = [self getCurrentDownloadTask:(NSURLSessionDownloadTask *)task];
    if (LLV_downloadTask.delegate &&
        [LLV_downloadTask.delegate respondsToSelector:@selector(LLVDownloadDidFinished:data:error:success:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error &&
                [error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"cancelled"]) {
                NSData * resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
                if (resumeData) {
                    [resumeData writeToFile:[self getResumeDataFilePath:LLV_downloadTask.saveFileName] atomically:YES];
                }
                if (LLV_downloadTask.delegate &&
                    [LLV_downloadTask.delegate respondsToSelector:@selector(LLVDownloadDidFinished:data:error:success:)]) {
                    [LLV_downloadTask.delegate LLVDownloadDidFinished:LLV_downloadTask
                                                                 data:nil
                                                                error:error
                                                              success:NO];
                }else {
                    if (LLV_downloadTask.didFinishedBlock) {
                        LLV_downloadTask.didFinishedBlock(LLV_downloadTask , nil , error , NO);
                    }
                }
                [self removeDownloadTask:LLV_downloadTask];
            }
        });
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    LLV_DownloadSessionTask * LLV_downloadTask = [self getCurrentDownloadTask:downloadTask];
    LLV_downloadTask.recvDataLenght += bytesWritten;
    LLV_downloadTask.orderTimeDataLenght += bytesWritten;
    if (LLV_downloadTask.actualFileSizeLenght < 10) {
        LLV_downloadTask.actualFileSizeLenght = totalBytesExpectedToWrite;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       if (LLV_downloadTask.delegate &&
           [LLV_downloadTask.delegate respondsToSelector:@selector(LLVDownloadProgress:recv:total:speed:)]) {
           [LLV_downloadTask.delegate LLVDownloadProgress:LLV_downloadTask
                                                     recv:totalBytesWritten
                                                    total:totalBytesExpectedToWrite
                                                    speed:LLV_downloadTask.networkSpeed];
       }else {
           if (LLV_downloadTask.progressBlock) {
               LLV_downloadTask.progressBlock(LLV_downloadTask ,
                                              totalBytesWritten ,
                                              totalBytesExpectedToWrite ,
                                              LLV_downloadTask.networkSpeed);
           }
       }
    });
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    LLV_DownloadSessionTask * LLV_downloadTask = [self getCurrentDownloadTask:downloadTask];
    LLV_downloadTask.orderTimeDataLenght = fileOffset;
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    LLV_DownloadSessionTask * LLV_downloadTask = [self getCurrentDownloadTask:(NSURLSessionDownloadTask *)dataTask];
    [LLV_downloadTask handleResponse:response];
    if (LLV_downloadTask.requestStatus == LLVHttpRequestFinished ) {
        [self removeDownloadTask:LLV_downloadTask];
    }
}
@end
