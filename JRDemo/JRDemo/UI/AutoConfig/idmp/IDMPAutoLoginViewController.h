//
//  IDMPAutoLoginViewController.h
//  IDMPMiddleWare-AlfredKing-CMCC
//
//  Created by alfredking－cmcc on 14-9-15.
//  Copyright (c) 2014年 alfredking－cmcc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IDMPAutoLoginViewController :NSObject

typedef void (^accessBlock)(NSDictionary *paraments);



/**
 *  此函数获取当前的网络状态，在主线程调用会有超时被系统强制结束造成应用崩溃的风险，需要在子线程中调用
 *
 *  @return 返回为0，表示同时开启wifi和蜂窝网络；返回为1，当前的网络为蜂窝网；返回2、3代表为wifi链接，但2有SIM卡，3可能有也可能没有；返回-1为错误
 */
- (int)getAuthType;


/**
 *  接口用于获取统一认证的身份标识.
 *
 *  @param userName     登陆的用户名.
 *  @param content      认证方式为1时值为用户密码,认证方式为2时值为短信验证码
 *  @param loginType    选择认证方式：1表示使用固定密码登陆,2表示使用临时密码登陆
 *  @param successBlock 登录成功之后执行的block方法，有调用者自行实现
 *  @param failBlock    登录失败之后执行的block方法，有调用者自行实现
 */
- (void)getAccessTokenByConditionWithUserName:(NSString *)userName Content:(NSString *)content andLoginType:(NSUInteger)loginType finishBlock:(accessBlock)successBlock failBlock:(accessBlock)failBlock;


/**
 *  接口用于获取统一认证的身份标识.建议和getAuthType一起使用.如果为sip应用需要返回应用密码则调用getAppPassword接口来完成。
 *
 *  @param userName        指定用户登陆时的用户名.可以传nil,如果没有缓存，会使用本机号码获取token,如果有缓存,会用缓存的号码获取token.
 *                         也可以传指定手机号,如果这个手机号有缓存,则直接用传入的手机号签发token;如果没有,则返回102314,缓存不存在.
 *  @param loginType       指定登录方式.0表示wifi和蜂窝网络同时开启时走蜂窝网络方式;1表示蜂窝网络方式,须开启蜂窝网络,wifi可开可不开;
 *                         2表示数据短信方式,须连接网络.
 *  @param isUserDefaultUI 不再支持，填写NO
 *  @param successBlock    登录成功之后使用的block方法，由应用开发者自行实现.
 *  @param failBlock       登录失败之后使用的block方法，由应用开发者自行实现.
 */
- (void)getAccessTokenWithUserName:(NSString *)userName andLoginType:(NSUInteger)loginType isUserDefaultUI:(BOOL)isUserDefaultUI finishBlock:(accessBlock)successBlock failBlock:(accessBlock)failBlock;


/**
 *  接口用于获取统一认证的应用密码（同时返回Token身份标示）；
 *
 *  @param userName     登陆的用户名
 *  @param content      认证方式为1值为用户密码;认证方式为2值为短信验证码
 *  @param loginType    选择认证方式.为1时使用固定密码登陆;为2时使用临时密码登陆
 *  @param successBlock 获取应用密码成功之后执行的block方法，有调用者自行实现
 *  @param failBlock    获取应用密码失败之后执行的block方法，有调用者自行实现
 */
- (void)getAppPasswordByConditionWithUserName:(NSString *)userName Content:(NSString *)content andLoginType:(NSUInteger)loginType finishBlock:(accessBlock)successBlock failBlock:(accessBlock)failBlock;


/**
 *  这一接口用于sip应用获取token以及sip密码.建议和getAuthType一起使用.
 *
 *  @param userName        指定用户登陆时的用户名.可以传nil,如果没有缓存，会使用本机号码获取token,如果有缓存,会用缓存的号码获取token.
 *                         也可以传指定手机号,如果这个手机号有缓存,则直接用传入的手机号签发token;如果没有,则返回102314,缓存不存在.
 *  @param loginType       指定登录方式.0表示wifi和蜂窝网络同时开启时走蜂窝网络方式;1表示蜂窝网络方式,须开启蜂窝网络,wifi可开可不开;
 *                         2表示数据短信方式,须连接网络.
 *  @param isUserDefaultUI 不再支持，填写NO
 *  @param successBlock    获取密码成功之后执行的block方法，有调用者自行实现
 *  @param failBlock       获取密码失败之后执行的block方法，有调用者自行实现
 */
- (void)getAppPasswordWithUserName:(NSString *)userName andLoginType:(NSUInteger)loginType isUserDefaultUI:(BOOL)isUserDefaultUI finishBlock:(accessBlock)successBlock failBlock:(accessBlock)failBlock;





/**
 *  接口用于第三方应用进行用户注册，本接口仅支持手机号码注册
 *
 *  @param phoneNo      手机号码；
 *  @param password     注册用户的密码；
 *  @param validCode    短信验证码；
 *  @param successBlock 注册用户成功时调用，由应用开发者自行实现。
 *  @param failBlock    注册用户失败时调用，由应用开发者自行实现。
 */
- (void)registerUserWithPhoneNo:(NSString *)phoneNo passWord:(NSString *)password andValidCode:(NSString *)validCode finishBlock:(accessBlock)successBlock failBlock:(accessBlock)failBlock;


/**
 *  接口用于第三方应用重置密码
 *
 *  @param phoneNo      手机号码；
 *  @param password     重置后的新密码；
 *  @param validCode    短信验证码
 *  @param successBlock 重置密码成功时调用，由应用开发者自行实现。
 *  @param failBlock    重置密码失败时调用，由应用开发者自行实现。
 */
- (void)resetPasswordWithPhoneNo:(NSString *)phoneNo passWord:(NSString *)password andValidCode:(NSString *)validCode finishBlock:(accessBlock)successBlock failBlock:(accessBlock)failBlock;


/**
 *  接口用于第三方应用密码修改
 *
 *  @param phoneNo      手机号码；
 *  @param password     旧密码；
 *  @param newpassword  新密码
 *  @param successBlock 修改密码成功时调用，由应用开发者自行实现。
 *  @param failBlock    修改密码失败时调用，由应用开发者自行实现。
 */
- (void)changePasswordWithPhoneNo:(NSString *)phoneNo passWord:(NSString *)password andNewPSW:(NSString *)newpassword finishBlock:(accessBlock)successBlock failBlock:(accessBlock)failBlock;


/**
 *  接口用于第三方应用在Token验证失败时调用此方法清理本地环境使用。
 *
 *  @return YES清除缓存成功
 */
- (BOOL)cleanSSO;


/**
 *  接口用于根据用户名清除其对应的缓存
 *
 *  @param userName 输入的用户名
 *
 *  @return YES清除缓存成功
 */
- (BOOL)cleanSSOWithUserName:(NSString *)userName;


- (void)currentEdition;



/**
 *	接口用于判断当前手机号码是否为本机号码
 *
 *  @param userName   手机号码；
 *
 *  @param successBlock 手机号码变化做的操作，由应用开发者自行实现。
 *  @param failBlock    手机号码不变(包括无法检测)的操作，由应用开发者自行实现。
 */
-(void)checkIsLocalNumberWith:(NSString *)userName finishBlock:(accessBlock) successBlock failBlock:(accessBlock )failBlock;


/**
 *	接口用于初始化appid、appkey、设置
 *
 *  @param appid        应用的AppID
 *  @param appkey       应用密钥
 *  @param aTime        请求超时时间等设置
 *  @param successBlock 初始化成功时调用，由应用开发者自行实现。
 *  @param failBlock    初始化失败时调用，由应用开发者自行实现。
 */
- (void)validateWithAppid:(NSString *)appid appkey:(NSString *)appkey timeoutInterval:(float)aTime   finishBlock:(accessBlock)successBlcok failBlock:(accessBlock)failBlock;


@end



