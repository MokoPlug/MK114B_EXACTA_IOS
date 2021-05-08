//
//  MKBMLPowerDataModel.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLPowerDataModel : NSObject

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, assign)BOOL switchIsOn;

@property (nonatomic, assign)BOOL overload;

@property (nonatomic, assign)float energyPower;

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
