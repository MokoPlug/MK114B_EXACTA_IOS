//
//  MKBMLSettingDataModel.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLSettingDataModel.h"

#import "MKMacroDefines.h"

#import "MKBMLInterface.h"

@interface MKBMLSettingDataModel ()

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKBMLSettingDataModel

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.readQueue, ^{
        if (![self readDeviceName]) {
            [self operationFailedBlockWithMsg:@"Read Device Name Error" block:failedBlock];
            return;
        }
        if (![self readAdvInterval]) {
            [self operationFailedBlockWithMsg:@"Read broadcast interval error" block:failedBlock];
            return ;
        }
        if (![self readOverloadValue]) {
            [self operationFailedBlockWithMsg:@"Read overload value error" block:failedBlock];
            return ;
        }
        if (![self readVCReportInterval]) {
            [self operationFailedBlockWithMsg:@"Read VC Report Interval error" block:failedBlock];
            return ;
        }
        if (![self readEnergyStorageParameters]) {
            [self operationFailedBlockWithMsg:@"Read power data error" block:failedBlock];
            return ;
        }
        if (![self readPulseConstant]) {
            [self operationFailedBlockWithMsg:@"Read energy data error" block:failedBlock];
            return ;
        }
        NSString *historicalEnergy = [self readHistoricalEnergy];
        if (!ValidStr(historicalEnergy)) {
            [self operationFailedBlockWithMsg:@"Read historicalEnergy data error" block:failedBlock];
            return ;
        }
        float tempValue = [historicalEnergy floatValue] / [self.pulseConstant floatValue];
        self.energyConsumption = [NSString stringWithFormat:@"%.2f",tempValue];
        
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

#pragma mark - interface
- (BOOL)readDeviceName {
    __block BOOL success = NO;
    [MKBMLInterface bml_readDeviceNameWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.deviceName = returnData[@"result"][@"deviceName"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readAdvInterval {
    __block BOOL success = NO;
    [MKBMLInterface bml_readAdvIntervalWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.advInterval = returnData[@"result"][@"interval"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readOverloadValue {
    __block BOOL success = NO;
    [MKBMLInterface bml_readOverloadProtectionValueWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.overloadValue = returnData[@"result"][@"value"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readVCReportInterval {
    __block BOOL success = NO;
    [MKBMLInterface bml_readVCReportIntervalWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.powerReInterval = returnData[@"result"][@"interval"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readEnergyStorageParameters {
    __block BOOL success = NO;
    [MKBMLInterface bml_readEnergyStorageParametersWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.energyReInterval = returnData[@"result"][@"recordInterval"];
        self.powerChangeNoti = returnData[@"result"][@"energyValue"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readPulseConstant {
    __block BOOL success = NO;
    [MKBMLInterface bml_readPulseConstantWithSucBlock:^(id  _Nonnull returnData) {
        self.pulseConstant = returnData[@"result"][@"pulseConstant"];
        dispatch_semaphore_signal(self.semaphore);
        success = YES;
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (NSString *)readHistoricalEnergy {
    __block NSString *value = nil;
    [MKBMLInterface bml_readAccumulatedEnergyWithSucBlock:^(id  _Nonnull returnData) {
        value = returnData[@"result"][@"value"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return value;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"settingsParams"
                                                    code:-999
                                                userInfo:@{@"errorInfo":msg}];
        block(error);
    })
}

#pragma mark - getter
- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)readQueue {
    if (!_readQueue) {
        _readQueue = dispatch_queue_create("settingsQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

@end
