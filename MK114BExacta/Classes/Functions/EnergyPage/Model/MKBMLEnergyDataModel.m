//
//  MKBMLEnergyDataModel.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLEnergyDataModel.h"

#import "MKMacroDefines.h"

#import "MKBMLInterface.h"

@interface MKBMLEnergyDataModel ()

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKBMLEnergyDataModel

- (void)startReadEnergyDatasWithScuBlock:(void (^)(NSArray *dailyList, NSArray *monthlyList, NSString *pulseConstant, NSString *deviceName))sucBlock failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.readQueue, ^{
        NSString *deviceName = [self readDeviceName];
        if (!deviceName) {
            [self operationFailedBlockWithMsg:@"Read deviceName error" block:failedBlock];
            return ;
        }
        NSString *pulseConstant = [self readPulseConstant];
        if (!pulseConstant) {
            [self operationFailedBlockWithMsg:@"Read pulseConstant error" block:failedBlock];
            return ;
        }
        NSArray *tempMonth = [self readMonthlyList];
        if (!tempMonth) {
            [self operationFailedBlockWithMsg:@"Read monthly data error" block:failedBlock];
            return ;
        }
        NSArray *tempDaily = [self readDailyList];
        if (!tempDaily) {
            [self operationFailedBlockWithMsg:@"Read daily data error" block:failedBlock];
            return ;
        }
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock(tempDaily,tempMonth,pulseConstant,deviceName);
            }
        });
    });
}

#pragma mark - interface
- (NSString *)readDeviceName {
    __block NSString *deviceName = nil;
    [MKBMLInterface bml_readDeviceNameWithSucBlock:^(id  _Nonnull returnData) {
        deviceName = returnData[@"result"][@"deviceName"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return deviceName;
}

- (NSString *)readPulseConstant {
    __block NSString *pulseConstant = nil;
    [MKBMLInterface bml_readPulseConstantWithSucBlock:^(id  _Nonnull returnData) {
        pulseConstant = returnData[@"result"][@"pulseConstant"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return pulseConstant;
}

- (NSArray *)readMonthlyList {
    __block NSArray *dataList = nil;
    [MKBMLInterface bml_readHistoricalEnergyWithSucBlock:^(id  _Nonnull returnData) {
        dataList = returnData[@"result"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return dataList;
}

- (NSArray *)readDailyList {
    __block NSArray *dataList = nil;
    [MKBMLInterface bml_readEnergyDataOfTodayWithSucBlock:^(id  _Nonnull returnData) {
        dataList = returnData[@"result"][@"dataList"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return dataList;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"readEnergyData"
                                                    code:-999
                                                userInfo:@{@"errorInfo":SafeStr(msg)}];
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
        _readQueue = dispatch_queue_create("readParamsQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

@end
