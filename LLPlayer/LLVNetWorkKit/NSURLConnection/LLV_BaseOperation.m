//
//  LLV_BaseOperation.m
//  LLVNetWorkKit
//
//  Created by 吴海超 on 15/11/6.
//  Copyright © 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windLLV/article/category/3117381
 */

#import "LLV_BaseOperation.h"
#import "LLV_HttpManager.h"

NSTimeInterval const kLLVRequestTimeout = 60;
NSTimeInterval const kLLVDownloadSpeedDuring = 1.5;
CGFloat        const kLLVWriteSizeLenght = 1024 * 1024;
NSString  * const  kLLVDomain = @"LLV_HTTP_OPERATION";
NSString  * const  kLLVInvainUrlError = @"无效的url:%@";
NSString  * const  kLLVCalculateFolderSpaceAvailableFailError = @"计算文件夹存储空间失败";
NSString  * const  kLLVErrorCode = @"错误码:%ld";
NSString  * const  kLLVFreeDiskSapceError = @"磁盘可用空间不足需要存储空间:%llu";
NSString  * const  kLLVRequestRange = @"bytes=%lld-";
NSString  * const  kLLVUploadCode = @"LLV";

@interface LLV_BaseOperation () {
    NSTimer * _speedTimer;
    NSThread * _thread;
}

@end

@implementation LLV_BaseOperation

#pragma mark - 重写属性方法 -
- (void)setStrUrl:(NSString *)strUrl {
    _strUrl = nil;
    _strUrl = strUrl.copy;
    NSString * newUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                              (CFStringRef)_strUrl,
                                                                                              (CFStringRef)@"!$&'()*-,-./:;=?@_~%#[]",
                                                                                              NULL,
                                                                                              kCFStringEncodingUTF8));
    _urlRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:newUrl]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeoutInterval = kLLVRequestTimeout;
        _requestType = LLVHttpRequestGet;
        _requestStatus = LLVHttpRequestNone;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _responseData = [NSMutableData data];
    }
    return self;
}

- (void)dealloc{
    [self cancelledRequest];
}


#pragma mark - 重写队列操作方法 -

- (void)start {
    @autoreleasepool {
        if ([NSURLConnection canHandleRequest:self.urlRequest]) {
            self.urlRequest.timeoutInterval = self.timeoutInterval;
            self.urlRequest.cachePolicy = self.cachePolicy;
            [_urlRequest setValue:self.contentType forHTTPHeaderField: @"Content-Type"];
            switch (self.requestType) {
                case LLVHttpRequestGet:
                case LLVHttpRequestFileDownload:{
                    [_urlRequest setHTTPMethod:@"GET"];
                }
                    break;
                case LLVHttpRequestPost:
                case LLVHttpRequestFileUpload:{
                    [_urlRequest setHTTPMethod:@"POST"];
                    if([LLV_HttpManager shared].cookie && [LLV_HttpManager shared].cookie.length > 0) {
                        [_urlRequest setValue:[LLV_HttpManager shared].cookie forHTTPHeaderField:@"Cookie"];
                    }
                    if (self.postParam != nil) {
                        NSData * paramData = nil;
                        if ([self.postParam isKindOfClass:[NSData class]]) {
                            paramData = (NSData *)self.postParam;
                        }else if ([self.postParam isKindOfClass:[NSString class]]) {
                            paramData = [((NSString *)self.postParam) dataUsingEncoding:self.encoderType allowLossyConversion:YES];
                        }
                        if (paramData) {
                            [_urlRequest setHTTPBody:paramData];
                            [_urlRequest setValue:[NSString stringWithFormat:@"%zd", paramData.length] forHTTPHeaderField: @"Content-Length"];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
            if(self.urlConnection == nil){
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                self.urlConnection = [[NSURLConnection alloc]initWithRequest:_urlRequest delegate:self startImmediately:NO];
            }
        }else {
            [self handleReqeustError:nil code:LLVGeneralError];
        }
    }
}

- (BOOL)isExecuting {
    return _requestStatus == LLVHttpRequestExecuting;
}

- (BOOL)isCancelled {
    BOOL isCancelled = _requestStatus == LLVHttpRequestCanceled ||
    _requestStatus == LLVHttpRequestFinished;
    if (isCancelled) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        _thread = nil;
    }
    return isCancelled;
}

- (BOOL)isFinished {
    BOOL isFinished = _requestStatus == LLVHttpRequestFinished;
    if (isFinished) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        _thread = nil;
    }
    return isFinished;
}

- (BOOL)isConcurrent{
    return YES;
}


#pragma mark - 公共方法 -

- (void)calculateNetworkSpeed {
    float downloadSpeed = (float)_orderTimeDataLenght / (kLLVDownloadSpeedDuring * 1024.0);
    _networkSpeed = [NSString stringWithFormat:@"%.1fKB/s", downloadSpeed];
    if (downloadSpeed >= 1024.0) {
        downloadSpeed = ((float)_orderTimeDataLenght / 1024.0) / (kLLVDownloadSpeedDuring * 1024.0);
        _networkSpeed = [NSString stringWithFormat:@"%.1fMB/s",downloadSpeed];
    }
    _orderTimeDataLenght = 0;
}


- (void)clearResponseData {
    [self.responseData resetBytesInRange:NSMakeRange(0, self.responseData.length)];
    [self.responseData setLength:0];
}

- (void)startRequest {
    [self willChangeValueForKey:@"isExecuting"];
    _requestStatus = LLVHttpRequestExecuting;
    [self didChangeValueForKey:@"isExecuting"];
    _thread = [NSThread currentThread];
    [_urlConnection start];
    CFRunLoopRun();
}

- (void)addDependOperation:(LLV_BaseOperation *)operation {
    [self addDependency:operation];
}

- (void)startSpeedTimer {
    if (!_speedTimer && (_requestType == LLVHttpRequestFileUpload ||
                         _requestType == LLVHttpRequestFileDownload ||
                         _requestType == LLVHttpRequestGet)) {
        _speedTimer = [NSTimer scheduledTimerWithTimeInterval:kLLVDownloadSpeedDuring
                                                       target:self
                                                     selector:@selector(calculateNetworkSpeed)
                                                     userInfo:nil
                                                      repeats:YES];
        [self calculateNetworkSpeed];
    }
}

- (BOOL)handleResponseError:(NSURLResponse * )response {
    BOOL isError = NO;
    NSHTTPURLResponse  *  headerResponse = (NSHTTPURLResponse *)response;
    if(headerResponse.statusCode >= 400){
        isError = YES;
        self.requestStatus = LLVHttpRequestFinished;
        if (self.requestType != LLVHttpRequestFileDownload) {
            [self cancelledRequest];
            NSError * error = [NSError errorWithDomain:kLLVDomain
                                                  code:LLVGeneralError
                                              userInfo:@{NSLocalizedDescriptionKey:
                                                             [NSString stringWithFormat:kLLVErrorCode,
                                                              (long)headerResponse.statusCode]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.didFinishedBlock) {
                    self.didFinishedBlock(self, nil , error , NO);
                    self.didFinishedBlock = nil;
                }else if (self.delegate &&
                          [self.delegate respondsToSelector:@selector(LLVDownloadDidFinished:data:error:success:)]) {
                    if (headerResponse.statusCode == 404) {
                        [[LLV_HttpManager shared].failedUrls addObject: self.strUrl];
                    }
                    [self.delegate LLVDownloadDidFinished:(LLV_DownloadOperation *)self data:nil error:error success:NO];
                }
            });
        }
    }else {
        _responseDataLenght = headerResponse.expectedContentLength;
        [self startSpeedTimer];
    }
    return isError;
}

- (void)endRequest {
    self.didFinishedBlock = nil;
    self.progressBlock = nil;
    [self cancelledRequest];
}

- (void)cancelledRequest{
    if (_urlConnection) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [_urlConnection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_urlConnection cancel];
        _urlConnection = nil;
        [self willChangeValueForKey:@"isCancelled"];
        [self willChangeValueForKey:@"isFinished"];
        _requestStatus = LLVHttpRequestFinished;
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isCancelled"];
        if (_requestType == LLVHttpRequestFileUpload ||
            _requestType == LLVHttpRequestFileDownload) {
            if (_speedTimer) {
                [_speedTimer invalidate];
                [_speedTimer fire];
                _speedTimer = nil;
            }
        }
    }
}

- (void)handleReqeustError:(NSError *)error code:(NSInteger)code {
    if(error == nil){
        error = [[NSError alloc]initWithDomain:kLLVDomain
                                          code:code
                                      userInfo:@{NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:kLLVInvainUrlError,self.strUrl]}];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.didFinishedBlock) {
            self.didFinishedBlock (self, nil, error , NO);
            self.didFinishedBlock = nil;
        }else if (self.delegate &&
                  [self.delegate respondsToSelector:@selector(LLVDownloadDidFinished:data:error:success:)]) {
            [self.delegate LLVDownloadDidFinished:(LLV_DownloadOperation *)self data:nil error:error success:NO];
        }
    });
    
}

@end
