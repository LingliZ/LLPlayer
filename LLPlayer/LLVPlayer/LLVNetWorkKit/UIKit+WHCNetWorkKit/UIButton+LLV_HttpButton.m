//
//  UIButton+LLV_HttpButton.m
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
#import "UIButton+LLV_HttpButton.h"
#import <objc/runtime.h>
#import "LLV_ImageCache.h"
#import "LLV_HttpManager.h"


@implementation UIButton (LLV_HttpButton)

- (NSMutableDictionary *)operationDictionary {
    NSMutableDictionary *operationDictionary = objc_getAssociatedObject([LLV_ImageCache shared], &loadOperationKey);
    if (!operationDictionary) {
        operationDictionary = [NSMutableDictionary dictionary];
        objc_setAssociatedObject([LLV_ImageCache shared],
                                 &loadOperationKey,
                                 operationDictionary,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return operationDictionary;
}

- (void)cancelOperationWithState:(UIControlState)state url:(NSString *)strUrl {
    NSMutableDictionary * operationDict = [self operationDictionary];
    LLV_BaseOperation * operation = [operationDict objectForKey:@(state).stringValue];
    if (operation) {
        if ([operation.strUrl isEqualToString:strUrl]){
            [[LLV_ImageCache shared].callBackDictionary removeObjectForKey:strUrl];
        }
        [operation cancelledRequest];
        [operationDict removeObjectForKey:@(state).stringValue];
    }
}

- (void)addOperation:(LLV_BaseOperation *)operation forState:(UIControlState)state {
    if (operation) {
        NSMutableDictionary * operationDict = [self operationDictionary];
        [operationDict setValue:operation forKey:@(state).stringValue];
    }
}

- (void)removeOperationForState:(UIControlState)state url:(NSString *)strUrl{
    NSMutableDictionary * operationDict = [self operationDictionary];
    [operationDict removeObjectForKey:@(state).stringValue];
    if ([operationDict.allKeys containsObject:@(state).stringValue]) {
        [[LLV_ImageCache shared].callBackDictionary removeObjectForKey:strUrl];
    }
}

- (void)LLV_setImageWithUrl:(nonnull NSString *)strUrl
                   forState:(UIControlState)state {
    [self LLV_setImageWithUrl:strUrl
                     forState:state placeholderImage:nil];
}

- (void)LLV_setImageWithUrl:(nonnull NSString *)strUrl
                   forState:(UIControlState)state
           placeholderImage:(nullable UIImage *)image {
    if (!strUrl && !image){
        return;
    }
    [self cancelOperationWithState:state url:strUrl];
    if (image) {
        [self setImage:image forState:state];
    }
    if (![[LLV_HttpManager shared].failedUrls containsObject:strUrl]){
        __weak typeof(self) weakSelf = self;
        [[LLV_ImageCache shared]queryImageForUrl:strUrl state:state didFinished:^(UIImage *image , UIControlState state) {
            if (!image) {
                if (![LLV_ImageCache shared].callBackDictionary[strUrl]) {
                    [LLV_ImageCache shared].callBackDictionary[strUrl] = [NSMutableArray array];
                   LLV_BaseOperation * operation = [[LLV_HttpManager shared] get:strUrl didFinished: ^(LLV_BaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
                             if (!isSuccess) {
                                 if (operation) {
                                     [[LLV_ImageCache shared].callBackDictionary removeObjectForKey:operation.strUrl];
                                 }
                             }else {
                                 UIImage * image = [UIImage imageWithData:data];
                                 [weakSelf setImage:image forState:state];
                                 [[LLV_ImageCache shared] storeImage:image forUrl:operation.strUrl];
                                 NSMutableArray * urlCallBackArr = [[LLV_ImageCache shared].callBackDictionary[operation.strUrl] copy];
                                 [[LLV_ImageCache shared].callBackDictionary removeObjectForKey:operation.strUrl];
                                 typedef  void (^callBack)(UIImage * image);
                                 for (NSMutableDictionary * dict in urlCallBackArr) {
                                     callBack cb = dict[@"completed"];
                                     cb(image);
                                 }
                             }
                         }];
                    [weakSelf addOperation:operation forState:state];
                }
                NSMutableArray *callbacksForURL = [LLV_ImageCache shared].callBackDictionary[strUrl];
                NSMutableDictionary *callbacks = [NSMutableDictionary dictionary];
                callbacks[@"completed"] = ^(UIImage * image){
                    [weakSelf setImage:image forState:state];
                };
                [callbacksForURL addObject:callbacks];
                [LLV_ImageCache shared].callBackDictionary[strUrl] = callbacksForURL;
            }else {
                [self setImage:image forState:state];
            }
        }];
    }
}


- (void)LLV_setBackgroundImageWithURL:(nonnull NSString *)strUrl
                             forState:(UIControlState)state {
    [self LLV_setBackgroundImageWithURL:strUrl
                               forState:state placeholderImage:nil];
}

- (void)LLV_setBackgroundImageWithURL:(nonnull NSString *)strUrl
                             forState:(UIControlState)state
                     placeholderImage:(nullable UIImage *)image {
    if (!strUrl && !image){
        return;
    }
    [self cancelOperationWithState:state url:strUrl];
    if (image) {
        [self setBackgroundImage:image forState:state];
    }
    if (![[LLV_HttpManager shared].failedUrls containsObject:strUrl]){
        __weak typeof(self) weakSelf = self;
        [[LLV_ImageCache shared]queryImageForUrl:strUrl state:state didFinished:^(UIImage *image , UIControlState state) {
            if (!image) {
                if (![LLV_ImageCache shared].callBackDictionary[strUrl]) {
                    [LLV_ImageCache shared].callBackDictionary[strUrl] = [NSMutableArray array];
                    LLV_BaseOperation * operation = [[LLV_HttpManager shared] get:strUrl didFinished: ^(LLV_BaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
                        if (!isSuccess) {
                            if (operation) {
                                [[LLV_ImageCache shared].callBackDictionary removeObjectForKey:operation.strUrl];
                            }
                        }else {
                            UIImage * image = [UIImage imageWithData:data];
                            [weakSelf setBackgroundImage:image forState:state];
                            [[LLV_ImageCache shared] storeImage:image forUrl:operation.strUrl];
                            NSMutableArray * urlCallBackArr = [[LLV_ImageCache shared].callBackDictionary[operation.strUrl] copy];
                            [[LLV_ImageCache shared].callBackDictionary removeObjectForKey:operation.strUrl];
                            typedef  void (^callBack)(UIImage * image);
                            for (NSMutableDictionary * dict in urlCallBackArr) {
                                callBack cb = dict[@"completed"];
                                cb(image);
                            }
                        }
                    }];
                    [weakSelf addOperation:operation forState:state];
                }
                NSMutableArray *callbacksForURL = [LLV_ImageCache shared].callBackDictionary[strUrl];
                NSMutableDictionary *callbacks = [NSMutableDictionary dictionary];
                callbacks[@"completed"] = ^(UIImage * image){
                    [weakSelf setBackgroundImage:image forState:state];
                };
                [callbacksForURL addObject:callbacks];
                [LLV_ImageCache shared].callBackDictionary[strUrl] = callbacksForURL;
            }else {
                [weakSelf setBackgroundImage:image forState:state];
            }
        }];
    }
}


@end
