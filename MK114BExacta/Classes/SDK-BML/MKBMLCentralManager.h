//
//  MKBMLCentralManager.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MKBaseBleModule/MKBLEBaseDataProtocol.h>

#import "MKBMLOperationID.h"

NS_ASSUME_NONNULL_BEGIN

//Notification of device connection status changes.
extern NSString *const mk_bml_peripheralConnectStateChangedNotification;

//Notification of changes in the status of the Bluetooth Center.
extern NSString *const mk_bml_centralManagerStateChangedNotification;

//Notification of switch status changes.
extern NSString *const mk_bml_receiveSwitchStatusChangedNotification;
//The device status changes to overload.
extern NSString *const mk_bml_receiveLoadStatusChangedNotification;
//Overload protection notice.
extern NSString *const mk_bml_receiveOverloadProtectionValueChangedNotification;
//Countdown notification of device switch status.
extern NSString *const mk_bml_receiveCountdownNotification;
//Notification of changes in voltage, electron current, and work and power.
extern NSString *const mk_bml_receiveEnergyVCPNotification;
//Current energy data of the device.
extern NSString *const mk_bml_receiveCurrentEnergyNotification;

@class CBCentralManager,CBPeripheral;
@class MKBMLDeviceModel;

typedef NS_ENUM(NSInteger, mk_bml_centralManagerStatus) {
    mk_bml_centralManagerStatusUnable,                           //不可用
    mk_bml_centralManagerStatusEnable,                           //可用状态
};

typedef NS_ENUM(NSInteger, mk_bml_centralConnectStatus) {
    mk_bml_centralConnectStatusUnknow,                                           //未知状态
    mk_bml_centralConnectStatusConnecting,                                       //正在连接
    mk_bml_centralConnectStatusConnected,                                        //连接成功
    mk_bml_centralConnectStatusConnectedFailed,                                  //连接失败
    mk_bml_centralConnectStatusDisconnect,
};

@protocol mk_bml_centralManagerScanDelegate <NSObject>

/// Scan to new device.
/// @param deviceModel device model
- (void)mk_bml_receiveDevice:(MKBMLDeviceModel *)deviceModel;

@optional

/// Starts scanning equipment.
- (void)mk_bml_startScan;

/// Stops scanning equipment.
- (void)mk_bml_stopScan;

@end

@interface MKBMLCentralManager : NSObject<MKBLEBaseCentralManagerProtocol>

@property (nonatomic, weak)id <mk_bml_centralManagerScanDelegate>delegate;

/// Current connection status
@property (nonatomic, assign, readonly)mk_bml_centralConnectStatus connectState;

+ (MKBMLCentralManager *)shared;

/// Destroy the MKBMLCentralManager singleton and the MKBLEBaseCentralManager singleton. After the dfu upgrade, you need to destroy these two and then reinitialize.
+ (void)sharedDealloc;

/// Destroy the MKBMLCentralManager singleton and remove the manager list of MKBLEBaseCentralManager.
+ (void)removeFromCentralList;

- (nonnull CBCentralManager *)centralManager;

/// Currently connected devices
- (nullable CBPeripheral *)peripheral;

/// Current Bluetooth center status
- (mk_bml_centralManagerStatus )centralStatus;

/// Bluetooth Center starts scanning
- (void)startScan;

/// Bluetooth center stops scanning
- (void)stopScan;

/// Connect device function
/// @param peripheral CBPeripheral
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
                 sucBlock:(void (^)(CBPeripheral *peripheral))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

/// disconnect
- (void)disconnect;

/// Start a task for data communication with the device
/// @param operationID operation id
/// @param characteristic characteristic for communication
/// @param resetNum How many data will the communication device return
/// @param commandData Data to be sent to the device for this communication
/// @param sucBlock Successful callback
/// @param failedBlock Failure callback
- (void)addTaskWithTaskID:(mk_bml_taskOperationID)operationID
           characteristic:(CBCharacteristic *)characteristic
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
                 sucBlock:(void (^)(id returnData))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;


@end

NS_ASSUME_NONNULL_END
