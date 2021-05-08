//
//  MKBMLAdopter.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLAdopter : NSObject

/// 解析电压(V)、电流(mA)、功率值(W)
/// @param value 前面2个字节代表电压，中间3个字节代表电流，最后2个字节代表功率
+ (NSDictionary *)parseVCPValue:(NSString *)value;

/// 解析历史累计电能
/// @param content content
+ (NSArray *)parseHistoricalEnergy:(NSString *)content;

/// 解析当天的电能数据
/// @param content content
+ (NSArray *)parseEnergyOfToday:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
