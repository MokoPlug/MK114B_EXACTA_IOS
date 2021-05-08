//
//  MKBMLTimerDataModel.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLTimerDataModel : NSObject

@property (nonatomic, copy)NSString *deviceName;

/*
 倒计时参数
 {
    "isOn":@(isOn),
    "configValue":configValue,
    "remainingTime":remainingTime,
 }
 */
@property (nonatomic, strong)NSDictionary *countdown;

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
