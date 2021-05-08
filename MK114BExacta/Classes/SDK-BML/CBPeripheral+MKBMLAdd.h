//
//  CBPeripheral+MKBMLAdd.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (MKBMLAdd)

/// WRITE_NO_RESPONSE / NOTIFY
@property (nonatomic, strong, readonly)CBCharacteristic *bml_read;
/// WRITE_NO_RESPONSE / NOTIFY
@property (nonatomic, strong, readonly)CBCharacteristic *bml_write;
/// WRITE_NO_RESPONSE / NOTIFY
@property (nonatomic, strong, readonly)CBCharacteristic *bml_state;

- (void)bml_updateCharacterWithService:(CBService *)service;

- (void)bml_updateCurrentNotifySuccess:(CBCharacteristic *)characteristic;

- (BOOL)bml_connectSuccess;

- (void)bml_setNil;

@end

NS_ASSUME_NONNULL_END
