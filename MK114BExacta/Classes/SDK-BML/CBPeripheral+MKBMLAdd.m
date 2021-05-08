//
//  CBPeripheral+MKBMLAdd.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "CBPeripheral+MKBMLAdd.h"

#import <objc/runtime.h>

static const char *readCharacterKey = "bml_readCharacterKey";
static const char *readCharacterNotifyKey = "bml_readCharacterNotifyKey";

static const char *writeCharacterKey = "bml_writeCharacterKey";
static const char *writeCharacterNotifyKey = "bml_writeCharacterNotifyKey";

static const char *stateCharacterKey = "bml_stateCharacterKey";
static const char *stateCharacterNotifyKey = "bml_stateCharacterNotifyKey";

@implementation CBPeripheral (MKBMLAdd)

- (void)bml_updateCharacterWithService:(CBService *)service {
    NSArray *characteristicList = service.characteristics;
    if (![service.UUID isEqual:[CBUUID UUIDWithString:@"FFB0"]] || characteristicList.count == 0) {
        return;
    }
    for (CBCharacteristic *characteristic in characteristicList) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB0"]]) {
            objc_setAssociatedObject(self, &readCharacterKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB1"]]) {
            objc_setAssociatedObject(self, &writeCharacterKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB2"]]) {
            objc_setAssociatedObject(self, &stateCharacterKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)bml_updateCurrentNotifySuccess:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB0"]]) {
        objc_setAssociatedObject(self, &readCharacterNotifyKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB1"]]) {
        objc_setAssociatedObject(self, &writeCharacterNotifyKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB2"]]) {
        objc_setAssociatedObject(self, &stateCharacterNotifyKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
}

- (BOOL)bml_connectSuccess {
    if (![objc_getAssociatedObject(self, &readCharacterNotifyKey) boolValue]
        || ![objc_getAssociatedObject(self, &writeCharacterNotifyKey) boolValue]
        || ![objc_getAssociatedObject(self, &stateCharacterNotifyKey) boolValue]) {
        return NO;
    }
    if (!self.bml_read || !self.bml_write || !self.bml_state) {
        return NO;
    }
    return YES;
}

- (void)bml_setNil {
    objc_setAssociatedObject(self, &readCharacterKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &readCharacterNotifyKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &writeCharacterKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &writeCharacterNotifyKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &stateCharacterKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &stateCharacterNotifyKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CBCharacteristic *)bml_read {
    return objc_getAssociatedObject(self, &readCharacterKey);
}

- (CBCharacteristic *)bml_write {
    return objc_getAssociatedObject(self, &writeCharacterKey);
}

- (CBCharacteristic *)bml_state {
    return objc_getAssociatedObject(self, &stateCharacterKey);
}

@end
