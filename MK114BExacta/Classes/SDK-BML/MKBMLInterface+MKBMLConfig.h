//
//  MKBMLInterface+MKBMLConfig.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLInterface.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_bml_plugSwitchStatus) {
    mk_bml_plugSwitchStatusPowerOff,        //the switch state is off when the device is just powered on.
    mk_bml_plugSwitchStatusPowerOn,         //the switch state is on when the device is just powered on
    mk_bml_plugSwitchStatusRevertLast,      //when the device is just powered on, the switch returns to the state before the power failure.
};

@protocol MKBMLDeviceTimeProtocol <NSObject>

@property (nonatomic, assign)NSInteger year;

@property (nonatomic, assign)NSInteger month;

@property (nonatomic, assign)NSInteger day;

@property (nonatomic, assign)NSInteger hour;

@property (nonatomic, assign)NSInteger minutes;

@property (nonatomic, assign)NSInteger second;

@end

@interface MKBMLInterface (MKBMLConfig)

/// Configure device broadcast name.
/// @param deviceName 1~16 ascii characters
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_configDeviceName:(NSString *)deviceName
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the broadcast interval.
/// @param interval 1~100,unit:100ms
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_configAdvInterval:(NSInteger)interval
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the switch state of the device.
/// @param isOn isOn
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_configSwitchStatus:(BOOL)isOn
                      sucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the power-on status of the device
/// @param status status
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_configPowerOnSwitchStatus:(mk_bml_plugSwitchStatus)status
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure overload protection value.
/// @param value 10W~3680W
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_configOverloadProtectionValue:(NSInteger)value
                                 sucBlock:(void (^)(void))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock;

/// Reset the accumulated energy.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_resetAccumulatedEnergyWithSucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the countdown. The countdown means that when the device counts as 0, the switch state is reversed from the current state.
/// @param seconds 0s~86400s
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_configCountdownValue:(long long)seconds
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

/// Reset.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_resetFactoryWithSucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure cumulative energy storage parameters.
/// @param interval Storage interval,1min—60min
/// @param energyValue Electric energy change value,1%-100%
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_configEnergyStorageParameters:(NSInteger)interval
                              energyValue:(NSInteger)energyValue
                                 sucBlock:(void (^)(void))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock;

/// Synchronize device time.
/// @param protocol protocol
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_configDeviceTime:(id <MKBMLDeviceTimeProtocol>)protocol
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure report interval for reading voltage and current data.
/// @param interval 1s~60s
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)bml_configVCReportInterval:(NSInteger)interval
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
