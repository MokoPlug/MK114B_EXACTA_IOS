//
//  MKBMLPowerDataModel.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLPowerDataModel.h"

#import "MKMacroDefines.h"

#import "MKBMLInterface.h"

@interface MKBMLPowerDataModel ()

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKBMLPowerDataModel

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.readQueue, ^{
        if (![self readDeviceName]) {
            [self operationFailedBlockWithMsg:@"Read Device Name Error" block:failedBlock];
            return;
        }
        if (![self readSwitchStatus]) {
            [self operationFailedBlockWithMsg:@"Read Switch Status Error" block:failedBlock];
            return;
        }
        if (![self readOverloadStatus]) {
            [self operationFailedBlockWithMsg:@"Read Overload Status Error" block:failedBlock];
            return;
        }
        if (![self readPowerDatas]) {
            [self operationFailedBlockWithMsg:@"Read Power Datas Error" block:failedBlock];
            return;
        }
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

- (BOOL)readSwitchStatus {
    __block BOOL success = NO;
    [MKBMLInterface bml_readSwitchStatusWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.switchIsOn = [returnData[@"result"][@"isOn"] boolValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readOverloadStatus {
    __block BOOL success = NO;
    [MKBMLInterface bml_readOverLoadStatusWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.overload = [returnData[@"result"][@"isOverLoad"] boolValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readPowerDatas {
    __block BOOL success = NO;
    [MKBMLInterface bml_readVCPValueWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.energyPower = [returnData[@"result"][@"p"] floatValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"powerParams"
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
        _readQueue = dispatch_queue_create("powerQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

@end
