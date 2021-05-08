//
//  MKBMLTaskAdopter.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLTaskAdopter.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "MKBLEBaseSDKAdopter.h"
#import "MKBLEBaseSDKDefines.h"

#import "MKBMLOperationID.h"
#import "MKBMLAdopter.h"

NSString *const mk_bml_communicationDataNum = @"mk_bml_communicationDataNum";
NSString *const mk_bml_historicalEnergyRecordDate = @"mk_bml_historicalEnergyRecordDate";

@implementation MKBMLTaskAdopter

+ (NSDictionary *)parseReadDataWithCharacteristic:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB0"]]) {
        //读取参数
        return [self parseFFB0Datas:characteristic];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB1"]]) {
        //设置参数
        return [self parseFFB1Datas:characteristic];
    }
    return @{};
}

+ (NSDictionary *)parseWriteDataWithCharacteristic:(CBCharacteristic *)characteristic {
    return @{};
}

#pragma mark - private method
+ (NSDictionary *)parseFFB0Datas:(CBCharacteristic *)characteristic {
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
    if (content.length < 8) {
        return @{};
    }
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b1"]) {
        return @{};
    }
    NSInteger len = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(4, 2)];
    if (content.length != 2 * len + 6) {
        return @{};
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    NSDictionary *returnDic = @{};
    mk_bml_taskOperationID operationID = mk_bml_defaultTaskOperationID;
    if ([function isEqualToString:@"01"]) {
        //读取设备名字
        NSData *subData = [characteristic.value subdataWithRange:NSMakeRange(3, len)];
        NSString *deviceName = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
        returnDic = @{
            @"deviceName":deviceName
        };
        operationID = mk_bml_taskReadDeviceNameOperation;
    }else if ([function isEqualToString:@"02"] && content.length == 8) {
        //读取广播间隔
        NSString *interval = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
        returnDic = @{
            @"interval":interval,
        };
        operationID = mk_bml_taskReadAdvIntervalOperation;
    }else if ([function isEqualToString:@"03"] && content.length == 8) {
        //读取开关状态
        BOOL isOn = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        returnDic = @{
            @"isOn":@(isOn),
        };
        operationID = mk_bml_taskReadSwitchStatusOperation;
    }else if ([function isEqualToString:@"04"] && content.length == 8) {
        //读取上电状态
        NSString *state = [content substringWithRange:NSMakeRange(6, 2)];
        returnDic = @{
            @"switchStatus":state,
        };
        operationID = mk_bml_taskReadPowerOnSwitchStatusOperation;
    }else if ([function isEqualToString:@"05"] && content.length == 8) {
        //读取负载状态
        BOOL loadStatus = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        returnDic = @{
            @"loadStatus":@(loadStatus),
        };
        operationID = mk_bml_taskReadLoadStatusOperation;
    }else if ([function isEqualToString:@"06"] && content.length == 10) {
        //读取过载保护值，单位为W
        NSString *value = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2 * len)];
        returnDic = @{
            @"value":value
        };
        operationID = mk_bml_taskReadOverloadProtectionValueOperation;
    }else if ([function isEqualToString:@"07"]) {
        //读取设备实时电压、电流、功率
        returnDic = [MKBMLAdopter parseVCPValue:[content substringWithRange:NSMakeRange(6, len * 2)]];
        operationID = mk_bml_taskReadVCPValueOperation;
    }else if ([function isEqualToString:@"08"] && content.length == 14) {
        //总的累计电能转数，实际电能为转数/脉冲常数 kwh
        NSString *value = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2 * len)];
        returnDic = @{
            @"value":value,
        };
        operationID = mk_bml_taskReadAccumulatedEnergyOperation;
    }else if ([function isEqualToString:@"09"] && content.length == 24) {
        //读取倒计时
        BOOL isOn = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        NSString *configValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 8)];
        NSString *remainingTime = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(16, 8)];
        returnDic = @{
            @"isOn":@(isOn),
            @"configValue":configValue,
            @"remainingTime":remainingTime,
        };
        operationID = mk_bml_taskReadCountdownValueOperation;
    }else if ([function isEqualToString:@"0a"]) {
        //读取固件版本
        NSData *subData = [characteristic.value subdataWithRange:NSMakeRange(3, len)];
        NSString *firmware = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
        returnDic = @{
            @"firmware":firmware
        };
        operationID = mk_bml_taskReadFirmwareVersionOperation;
    }else if ([function isEqualToString:@"0b"] && content.length == 18) {
        //读取mac地址
        NSString *tempMac = [[content substringWithRange:NSMakeRange(6, 12)] uppercaseString];
        NSString *macAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[tempMac substringWithRange:NSMakeRange(0, 2)],[tempMac substringWithRange:NSMakeRange(2, 2)],[tempMac substringWithRange:NSMakeRange(4, 2)],[tempMac substringWithRange:NSMakeRange(6, 2)],[tempMac substringWithRange:NSMakeRange(8, 2)],[tempMac substringWithRange:NSMakeRange(10, 2)]];
        returnDic = @{
            @"macAddress":macAddress
        };
        operationID = mk_bml_taskReadMacAddressOperation;
    }else if ([function isEqualToString:@"0c"] && content.length == 10) {
        //读取累计电能存储参数
        NSString *recordInterval = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
        NSString *energyValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
        returnDic = @{
            @"recordInterval":recordInterval,
            @"energyValue":energyValue
        };
        operationID = mk_bml_taskReadEnergyStorageParametersOperation;
    }else if ([function isEqualToString:@"0d"]) {
        //读取历史累计电能条数
        NSDictionary *dateDic = @{};
        if (len == 7) {
            //存在历史数据
            NSString *year = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 4)];
            NSString *month = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(12, 2)];
            if (month.length == 1) {
                month = [@"0" stringByAppendingString:month];
            }
            NSString *day = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(14, 2)];
            if (day.length == 1) {
                day = [@"0" stringByAppendingString:day];
            }
            NSString *hour = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(16, 2)];
            if (hour.length == 1) {
                hour = [@"0" stringByAppendingString:hour];
            }
            NSString *minute = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(18, 2)];
            if (minute.length == 1) {
                minute = [@"0" stringByAppendingString:minute];
            }
            dateDic = @{
                @"year":year,
                @"month":month,
                @"day":day,
                @"hour":hour,
                @"minute":minute
            };
        }
        returnDic = @{
                       mk_bml_communicationDataNum:[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                       mk_bml_historicalEnergyRecordDate:dateDic
                       };
        operationID = mk_bml_taskReadHistoricalEnergyOperation;
    }else if ([function isEqualToString:@"0e"]) {
        //累计电能详细数据
        NSString *subContent = [content substringWithRange:NSMakeRange(6, 2 * len)];
        NSArray *dataList = [MKBMLAdopter parseHistoricalEnergy:subContent];
        returnDic = @{
            @"dataList":dataList
        };
        operationID = mk_bml_taskReadHistoricalEnergyOperation;
    }else if ([function isEqualToString:@"10"] && content.length == 12) {
        //读取过载状态
        BOOL isOverLoad = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        NSString *value = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 4)];
        returnDic = @{
            @"isOverLoad":@(isOverLoad),
            @"overLoadValue":value
        };
        operationID = mk_bml_taskReadOverLoadStatusOperation;
    }else if ([function isEqualToString:@"11"]){
        //当天电能总条数
        NSString *energyPower = @"";
        if (len == 4) {
            energyPower = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 6)];
        }
        returnDic = @{
        mk_bml_communicationDataNum:[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
        @"energyPower":energyPower
        };
        operationID = mk_bml_taskReadEnergyDataOfTodayOperation;
    }else if ([function isEqualToString:@"12"]) {
        //当天每小时电能数据详情
        NSString *subContent = [content substringFromIndex:6];
        NSArray *dataList = [MKBMLAdopter parseEnergyOfToday:subContent];
        returnDic = @{
            @"dataList":dataList
        };
        operationID = mk_bml_taskReadEnergyDataOfTodayOperation;
    }else if ([function isEqualToString:@"13"] && content.length == 10) {
        //读取脉冲常数
        NSString *value = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)];
        returnDic = @{
            @"pulseConstant":value,
        };
        operationID = mk_bml_taskReadPulseConstantOperation;
    }else if ([function isEqualToString:@"14"] && content.length == 8) {
        //读取电压电流上报间隔
        NSString *interval = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
        returnDic = @{
            @"interval":interval,
        };
        operationID = mk_bml_taskReadVCReportIntervalOperation;
    }
    
    return [self dataParserGetDataSuccess:returnDic operationID:operationID];
}

+ (NSDictionary *)parseFFB1Datas:(CBCharacteristic *)characteristic {
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
    if (content.length != 8) {
        return @{};
    }
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b3"]) {
        return @{};
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    mk_bml_taskOperationID operationID = mk_bml_defaultTaskOperationID;
    if ([function isEqualToString:@"01"]) {
        operationID = mk_bml_taskConfigDeviceNameOperation;
    }else if ([function isEqualToString:@"02"]) {
        operationID = mk_bml_taskConfigAdvIntervalOperation;
    }else if ([function isEqualToString:@"03"]) {
        operationID = mk_bml_taskConfigSwitchStatusOperation;
    }else if ([function isEqualToString:@"04"]) {
        operationID = mk_bml_taskConfigPowerOnSwitchStatusOperation;
    }else if ([function isEqualToString:@"05"]) {
        operationID = mk_bml_taskConfigOverloadProtectionValueOperation;
    }else if ([function isEqualToString:@"06"]) {
        operationID = mk_bml_taskResetAccumulatedEnergyOperation;
    }else if ([function isEqualToString:@"07"]) {
        operationID = mk_bml_taskConfigCountdownValueOperation;
    }else if ([function isEqualToString:@"08"]) {
        operationID = mk_bml_taskResetFactoryOperation;
    }else if ([function isEqualToString:@"09"]) {
        operationID = mk_bml_taskConfigEnergyStorageParametersOperation;
    }else if ([function isEqualToString:@"0a"]) {
        operationID = mk_bml_taskConfigDeviceDateOperation;
    }else if ([function isEqualToString:@"0b"]) {
        operationID = mk_bml_taskConfigVCReportIntervalOperation;
    }
    BOOL success = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"00"];
    NSDictionary *returnDic = @{
        @"result":@(success),
    };
    return [self dataParserGetDataSuccess:returnDic operationID:operationID];
}

+ (NSDictionary *)dataParserGetDataSuccess:(NSDictionary *)returnData operationID:(mk_bml_taskOperationID)operationID{
    if (!returnData) {
        return nil;
    }
    return @{@"returnData":returnData,@"operationID":@(operationID)};
}

@end
