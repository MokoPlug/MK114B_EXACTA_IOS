//
//  MKBMLEnergyDataModel.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLEnergyDataModel : NSObject

- (void)startReadEnergyDatasWithScuBlock:(void (^)(NSArray *dailyList, NSArray *monthlyList, NSString *pulseConstant, NSString *deviceName))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
