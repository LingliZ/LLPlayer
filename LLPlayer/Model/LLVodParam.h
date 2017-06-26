//
//  LLVodParam.h
//  xdfapp
//
//  Created by tony on 2017/6/15.
//  Copyright © 2017年 xdf.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PlayerSDK/VodDownLoader.h>
/**
 点播参数
 */
@interface LLVodParam: NSObject


/**
 域名
 */
@property (nonatomic, copy) NSString *domain;


/**
 点播ID
 */
@property (nonatomic, copy) NSString *vodID;


/**
 点播编号
 */
@property (nonatomic, copy) NSString *number;


/**
 观看密码
 */
@property (nonatomic, copy) NSString *vodPassword;


/**
 观看时昵称
 */
@property (nonatomic, copy) NSString *nickName;


/**
 登录站点用户名，若后台设置为不用登录 也可观看则不需要此参数
 */
@property (nonatomic, copy) NSString *loginName;

/**
 登录站点密码，若后台设置为不用登录 也可观看则不需要此参数
 */
@property (nonatomic, copy) NSString *loginPassword;

/**
 是否采用老的接口，默认为NO，一般情况下请不要设置为YES
 */
@property (nonatomic, assign) BOOL oldVersion;


/**
 第三方验证token，配合后台设置使用，若后台无设置，则不需要填写，若oldVersion为YES，则此参数不起作用
 */
@property (nonatomic, copy) NSString *thirdToken;


/**
 自定义用户ID，无特殊要求不需要设置，平台会自动分配，若要设置，请设置为大于十亿的数字
 */
@property (nonatomic, assign) long long  customUserID;


/**
 是否为Box客户，默认为NO， 一般客户不需要设置， Box客户为后台单独部署，不和我们的站点一起更新，Box客户的域名一般不是 “*.gensee.com”
 */
@property (nonatomic, assign) BOOL isBox;


/**
 是否需要下载，1需要，0不需要
 */
@property (nonatomic, assign) int downFlag;


/**
 服务类型，webcast或training
 */
@property (nonatomic, copy) NSString *serviceType;

- (VodParam *)vodParam;

@end
