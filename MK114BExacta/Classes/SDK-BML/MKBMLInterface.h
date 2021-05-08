//
//  MKBMLInterface.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLInterface : NSObject

/// Read the broadcast name of the device.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readDeviceNameWithSucBlock:(void (^)(id returnData))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the broadcast interval, the unit is 100ms.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readAdvIntervalWithSucBlock:(void (^)(id returnData))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the current switch state.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readSwitchStatusWithSucBlock:(void (^)(id returnData))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the switch state when the device is just powered on. 0x00 means that the switch state is off when the device is just powered on, 0x01 means that the switch state is on when the device is just powered on, and 0x02 means that when the device is just powered on, the switch returns to the state before the power failure.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readPowerOnSwitchStatusWithSucBlock:(void (^)(id returnData))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Read load status.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readLoadStatusWithSucBlock:(void (^)(id returnData))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the overload protection value, the unit is W.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readOverloadProtectionValueWithSucBlock:(void (^)(id returnData))sucBlock
                                        failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the real-time voltage, current, and power of the device. The voltage unit is 0.1V, the current unit is mA, and the power unit is 0.1W.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readVCPValueWithSucBlock:(void (^)(id returnData))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the accumulated electric energy, the total accumulated electric energy revolutions, the actual electric energy is the revolutions/pulse constant kwh.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readAccumulatedEnergyWithSucBlock:(void (^)(id returnData))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the countdown. The countdown means that when the device counts as 0, the switch state is reversed from the current state.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readCountdownValueWithSucBlock:(void (^)(id returnData))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock;

/// Read firmware version.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readFirmwareVersionWithSucBlock:(void (^)(id returnData))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock;

/// Read MAC address.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readMacAddressWithSucBlock:(void (^)(id returnData))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock;

/// Read accumulated electric energy storage parameters.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readEnergyStorageParametersWithSucBlock:(void (^)(id returnData))sucBlock
                                        failedBlock:(void (^)(NSError *error))failedBlock;

/// Read historical accumulated electric energy, up to 30 days of data.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readHistoricalEnergyWithSucBlock:(void (^)(id returnData))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock;

/// Read overload status.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readOverLoadStatusWithSucBlock:(void (^)(id returnData))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock;

/// Read hourly data of the day.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readEnergyDataOfTodayWithSucBlock:(void (^)(id returnData))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Read pulse constant.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readPulseConstantWithSucBlock:(void (^)(id returnData))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock;

/// Read report interval for reading voltage and current data.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_readVCReportIntervalWithSucBlock:(void (^)(id returnData))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
