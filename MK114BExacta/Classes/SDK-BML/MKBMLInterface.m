//
//  MKBMLInterface.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLInterface.h"

#import "MKBMLCentralManager.h"
#import "CBPeripheral+MKBMLAdd.h"
#import "MKBMLOperationID.h"

#define centralManager [MKBMLCentralManager shared]
#define peripheral [MKBMLCentralManager shared].peripheral

@implementation MKBMLInterface

+ (void)bml_readDeviceNameWithSucBlock:(void (^)(id returnData))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadDeviceNameOperation
                         cmd:@"01"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readAdvIntervalWithSucBlock:(void (^)(id returnData))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadAdvIntervalOperation
                         cmd:@"02"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readSwitchStatusWithSucBlock:(void (^)(id returnData))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadSwitchStatusOperation
                         cmd:@"03"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readPowerOnSwitchStatusWithSucBlock:(void (^)(id returnData))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadPowerOnSwitchStatusOperation
                         cmd:@"04"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readLoadStatusWithSucBlock:(void (^)(id returnData))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadLoadStatusOperation
                         cmd:@"05"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readOverloadProtectionValueWithSucBlock:(void (^)(id returnData))sucBlock
                                        failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadOverloadProtectionValueOperation
                         cmd:@"06"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readVCPValueWithSucBlock:(void (^)(id returnData))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadVCPValueOperation
                         cmd:@"07"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readAccumulatedEnergyWithSucBlock:(void (^)(id returnData))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadAccumulatedEnergyOperation
                         cmd:@"08"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readCountdownValueWithSucBlock:(void (^)(id returnData))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadCountdownValueOperation
                         cmd:@"09"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readFirmwareVersionWithSucBlock:(void (^)(id returnData))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadFirmwareVersionOperation
                         cmd:@"0a"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readMacAddressWithSucBlock:(void (^)(id returnData))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadMacAddressOperation
                         cmd:@"0b"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readEnergyStorageParametersWithSucBlock:(void (^)(id returnData))sucBlock
                                        failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadEnergyStorageParametersOperation
                         cmd:@"0c"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readHistoricalEnergyWithSucBlock:(void (^)(id returnData))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:mk_bml_taskReadHistoricalEnergyOperation
                       characteristic:peripheral.bml_read
                             resetNum:YES
                          commandData:@"b00d00"
                             sucBlock:^(id  _Nonnull returnData) {
        NSDictionary *dic = [self parseHistoricalEnergy:returnData[@"result"]];
        sucBlock(dic);
    }
                          failedBlock:failedBlock];
}

+ (void)bml_readOverLoadStatusWithSucBlock:(void (^)(id returnData))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadOverLoadStatusOperation
                         cmd:@"10"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readEnergyDataOfTodayWithSucBlock:(void (^)(id returnData))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:mk_bml_taskReadEnergyDataOfTodayOperation
                       characteristic:peripheral.bml_read
                             resetNum:YES
                          commandData:@"b01100"
                             sucBlock:^(id  _Nonnull returnData) {
        NSDictionary *dic = [self parseEnergyOfToday:returnData[@"result"]];
        sucBlock(dic);
    }
                          failedBlock:failedBlock];
}

+ (void)bml_readPulseConstantWithSucBlock:(void (^)(id returnData))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadPulseConstantOperation
                         cmd:@"13"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

+ (void)bml_readVCReportIntervalWithSucBlock:(void (^)(id returnData))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock {
    [self readDataWithTaskID:mk_bml_taskReadVCReportIntervalOperation
                         cmd:@"14"
                    sucBlcok:sucBlock
                 failedBlock:failedBlock];
}

#pragma mark - private method
+ (void)readDataWithTaskID:(mk_bml_taskOperationID)taskID
                       cmd:(NSString *)cmd
                  sucBlcok:(void (^)(id returnData))sucBlock
               failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = [NSString stringWithFormat:@"b0%@00",cmd];
    [centralManager addTaskWithTaskID:taskID
                       characteristic:peripheral.bml_read
                             resetNum:NO
                          commandData:commandString
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (NSDictionary *)parseHistoricalEnergy:(NSDictionary *)resultDic {
    NSUInteger number = [resultDic[@"mk_bml_additionalInformation"][@"mk_bml_communicationDataNum"] integerValue];
    NSArray *dataList = resultDic[@"mk_bml_dataInformation"];
    if (number == 0 || dataList.count != number) {
        //没有电能数据
        return @{
            @"msg":@"success",
            @"code":@"1",
            @"result":@[],
        };
    }
    NSDictionary *recordDateDic = resultDic[@"mk_bml_additionalInformation"][@"mk_bml_historicalEnergyRecordDate"];
    NSString *recordTime = [NSString stringWithFormat:@"%@-%@-%@",recordDateDic[@"year"],recordDateDic[@"month"],recordDateDic[@"day"]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *recordDate = [dateFormat dateFromString:recordTime];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *dic in dataList) {
        NSInteger index = [dic[@"index"] integerValue];
        NSDate *tempDate = [[NSDate alloc] initWithTimeInterval:(24 * 60 * 60 * index) sinceDate:recordDate];
        NSString *tempTime = [dateFormat stringFromDate:tempDate];
        NSDictionary *tempDic = @{
            @"date":tempTime,
            @"rotationsNumber":dic[@"rotationsNumber"],
            @"index":dic[@"index"],
        };
        [list addObject:tempDic];
    }
    return @{
        @"msg":@"success",
        @"code":@"1",
        @"result":list,
    };
}

+ (NSDictionary *)parseEnergyOfToday:(NSDictionary *)resultDic {
    NSUInteger number = [resultDic[@"mk_bml_additionalInformation"][@"mk_bml_communicationDataNum"] integerValue];
    NSArray *dataList = resultDic[@"mk_bml_dataInformation"];
    if (number == 0 || dataList.count != number) {
        //没有电能数据
        return @{
            @"msg":@"success",
            @"code":@"1",
            @"result":@[],
        };
    }
    return @{
        @"msg":@"success",
        @"code":@"1",
        @"result":@{
                @"dataList":dataList,
                @"energyPower":resultDic[@"mk_bml_additionalInformation"][@"energyPower"],
        },
    };
}

@end
