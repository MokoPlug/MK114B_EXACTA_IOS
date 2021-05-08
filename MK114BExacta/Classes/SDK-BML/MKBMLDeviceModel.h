//
//  MKBMLDeviceModel.h
//  MK114BExacta
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral;
@interface MKBMLDeviceModel : NSObject

@property (nonatomic, strong)CBPeripheral *peripheral;

@property (nonatomic, assign)NSInteger rssi;

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, copy)NSString *macAddress;

/// Voltage(V)
@property (nonatomic, assign)CGFloat electronV;

/// electron current(mA)
@property (nonatomic, assign)NSInteger electronA;

/// work and power(W)
@property (nonatomic, assign)float electronP;

/// Load detection.
@property (nonatomic, assign)BOOL loadDetection;

/// Whether the device is overloaded.
@property (nonatomic, assign)BOOL overloadState;

/// The switch state of the plug.
@property (nonatomic, assign)BOOL switchStatus;

@end

NS_ASSUME_NONNULL_END
