//
//  MKBMLDeviceInfoModel.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLDeviceInfoModel : NSObject

@property (nonatomic, copy)NSString *companyName;

@property (nonatomic, copy)NSString *productName;

@property (nonatomic, copy)NSString *firmware;

@property (nonatomic, copy)NSString *deviceMac;

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
