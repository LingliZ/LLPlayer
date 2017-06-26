//
//  UIImageView+LLV_HttpImageView.m
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
#import "UIImageView+LLV_HttpImageView.h"
#import <objc/runtime.h>
#import "LLV_ImageCache.h"
#import "LLV_HttpManager.h"
#import <ImageIO/ImageIO.h>

@implementation UIImageView (LLV_HttpImageView)

- (NSMutableDictionary *)operationDictionary {
    NSMutableDictionary *operationDictionary = objc_getAssociatedObject([LLV_ImageCache shared], &loadOperationKey);
    if (!operationDictionary) {
        operationDictionary = [NSMutableDictionary dictionary];
        objc_setAssociatedObject([LLV_ImageCache shared], &loadOperationKey, operationDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return operationDictionary;
}

- (void)cancelOperationWithUrl:(NSString *)strUrl {
    NSMutableDictionary * operationDictionary = [self operationDictionary];
    LLV_BaseOperation * operation = [operationDictionary objectForKey:strUrl];
    if (operation) {
        [[LLV_ImageCache shared].callBackDictionary removeObjectForKey:strUrl];
        [operation cancelledRequest];
        [operationDictionary removeObjectForKey:strUrl];
    }
}

- (void)addOperation:(LLV_BaseOperation *)operation url:(NSString *)strUrl{
    if (operation) {
        NSMutableDictionary * operationDict = [self operationDictionary];
        [operationDict setValue:operation forKey:strUrl];
    }
}

- (void)removeOperationForUrl:(NSString *)strUrl{
    NSMutableDictionary * operationDict = [self operationDictionary];
    [operationDict removeObjectForKey:strUrl];
    [[LLV_ImageCache shared].callBackDictionary removeObjectForKey:strUrl];
}

- (void)LLV_setImageWithUrl:(nonnull NSString *)strUrl {
    [self LLV_setImageWithUrl:strUrl placeholderImage:nil];
}

- (void)LLV_setImageWithUrl:(nonnull NSString *)strUrl placeholderImage:(nullable UIImage *)image {
    if (!strUrl && !image){
        return;
    }
    [self cancelOperationWithUrl:strUrl];
    if (image) {
        [self setImage:image];
    }
    if (![[LLV_HttpManager shared].failedUrls containsObject:strUrl]){
        __weak typeof(self) weakSelf = self;
        [[LLV_ImageCache shared]queryImageForUrl:strUrl
                                           state:UIControlStateNormal
                                     didFinished:^(UIImage *image , UIControlState state) {
            if (!image) {
                if (![LLV_ImageCache shared].callBackDictionary[strUrl]) {
                    [LLV_ImageCache shared].callBackDictionary[strUrl] = [NSMutableArray array];
                    LLV_BaseOperation * operation = [[LLV_HttpManager shared] get:strUrl didFinished: ^(LLV_BaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
                        if (!isSuccess) {
                            if (operation) {
                                [[LLV_ImageCache shared].callBackDictionary removeObjectForKey:operation.strUrl];
                            }
                        }else {
                            UIImage * image = nil;
                            if ([[[LLV_HttpManager shared] fileFormatWithUrl:operation.strUrl] isEqualToString:@".gif"]) {
                                image = [self gifImageWithData:data];
                            }else {
                                image = [UIImage imageWithData:data];
                            }
                            [weakSelf setImage:image];
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
                    [weakSelf addOperation:operation url:strUrl];
                }
                NSMutableArray *callbacksForURL = [LLV_ImageCache shared].callBackDictionary[strUrl];
                NSMutableDictionary *callbacks = [NSMutableDictionary dictionary];
                callbacks[@"completed"] = ^(UIImage * image){
                    [weakSelf setImage:image];
                };
                [callbacksForURL addObject:callbacks];
                [LLV_ImageCache shared].callBackDictionary[strUrl] = callbacksForURL;
            }else {
                [self setImage:image];
            }
        }];
    }
}

- (void)setGifWithPath:(nonnull NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.image = [self gifImageWithData:data];
}

- (UIImage *)gifImageWithData:(NSData *)gifData{
    NSMutableArray  * imageArr = [NSMutableArray array];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef) gifData, NULL);
    NSTimeInterval animationDuration = 0.0;
    if (src) {
        NSUInteger frameCount = CGImageSourceGetCount(src);
        NSDictionary *gifProperties = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyProperties(src, NULL));
        if(gifProperties) {
            NSDictionary *gifDictionary =[gifProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary];
            NSUInteger loopCount = [[gifDictionary objectForKey:(NSString*)kCGImagePropertyGIFLoopCount] integerValue];
            self.animationRepeatCount = loopCount;
            for (NSUInteger i = 0; i < frameCount; i++) {
                CGImageRef img = CGImageSourceCreateImageAtIndex(src, (size_t) i, NULL);
                if (img) {
                    UIImage *frameImage = [UIImage imageWithCGImage:img];
                    if(frameImage){
                        [imageArr addObject:frameImage];
                    }
                    NSDictionary *frameProperties = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, (size_t) i, NULL));
                    if (frameProperties) {
                        NSDictionary *frameDictionary = [frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary];
                        CGFloat delayTime = [[frameDictionary objectForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
                        animationDuration += delayTime;
                    }
                    CGImageRelease(img);
                }
            }
        }
        CFRelease(src);
    }
    return [UIImage animatedImageWithImages:imageArr duration:animationDuration];
}

@end
