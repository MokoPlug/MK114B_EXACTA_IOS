//
//  MKBMLSettingDataModel.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLSettingDataModel : NSObject

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, copy)NSString *advInterval;

@property (nonatomic, copy)NSString *overloadValue;

@property (nonatomic, copy)NSString *powerReInterval;

@property (nonatomic, copy)NSString *energyReInterval;

@property (nonatomic, copy)NSString *powerChangeNoti;

@property (nonatomic, copy)NSString *pulseConstant;

@property (nonatomic, copy)NSString *energyConsumption;

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
