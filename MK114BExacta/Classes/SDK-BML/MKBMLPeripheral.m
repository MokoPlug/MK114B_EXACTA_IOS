//
//  MKBMLPeripheral.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLPeripheral.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "CBPeripheral+MKBMLAdd.h"

@interface MKBMLPeripheral ()

@property (nonatomic, strong)CBPeripheral *peripheral;

@end

@implementation MKBMLPeripheral

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    if (self = [super init]) {
        self.peripheral = peripheral;
    }
    return self;
}

- (void)discoverServices {
    NSArray *services = @[[CBUUID UUIDWithString:@"FFB0"]]; //自定义服务
    [self.peripheral discoverServices:services];
}

- (void)discoverCharacteristics {
    for (CBService *service in self.peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFB0"]]) {
            NSArray *charList = @[[CBUUID UUIDWithString:@"FFB0"],
                                  [CBUUID UUIDWithString:@"FFB1"],
                                  [CBUUID UUIDWithString:@"FFB2"]];
            [self.peripheral discoverCharacteristics:charList forService:service];
            break;
        }
    }
}

- (void)updateCharacterWithService:(CBService *)service {
    [self.peripheral bml_updateCharacterWithService:service];
}

- (void)updateCurrentNotifySuccess:(CBCharacteristic *)characteristic {
    [self.peripheral bml_updateCurrentNotifySuccess:characteristic];
}

- (BOOL)connectSuccess {
    return [self.peripheral bml_connectSuccess];
}

- (void)setNil {
    [self.peripheral bml_setNil];
}

@end
