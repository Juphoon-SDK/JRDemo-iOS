//
//  IDMPTempSmsMode.h
//  IDMPMiddleWare-AlfredKing-CMCC
//
//  Created by alfredking－cmcc on 14-8-21.
//  Copyright (c) 2014年 alfredking－cmcc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDMPTempSmsMode : NSObject

typedef void (^IDMPBlock)(void);
typedef void (^accessBlock)(NSDictionary *paraments);

- (void)getSmsCodeWithUserName:(NSString*)userName busiType:(NSString *)busiType successBlock:(accessBlock)successBlock failBlock:(accessBlock)failBlock;

-(void)getTMKSWithSipInfo: (NSString *)sipinfo UserName:(NSString *)userName messageCode:(NSString *)messageCode successBlock:(accessBlock)successBlock failBlock:(accessBlock)failBlock;

@end
