//
//  MKBMLCentralManager.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLCentralManager.h"

#import "MKBLEBaseCentralManager.h"
#import "MKBLEBaseSDKDefines.h"
#import "MKBLEBaseSDKAdopter.h"
#import "MKBLEBaseLogManager.h"

#import "MKBMLPeripheral.h"
#import "MKBMLOperation.h"
#import "MKBMLTaskAdopter.h"
#import "CBPeripheral+MKBMLAdd.h"
#import "MKBMLDeviceModel.h"
#import "MKBMLAdopter.h"

NSString *const mk_bml_peripheralConnectStateChangedNotification = @"mk_bml_peripheralConnectStateChangedNotification";
NSString *const mk_bml_centralManagerStateChangedNotification = @"mk_bml_centralManagerStateChangedNotification";

NSString *const mk_bml_receiveSwitchStatusChangedNotification = @"mk_bml_receiveSwitchStatusChangedNotification";
NSString *const mk_bml_receiveLoadStatusChangedNotification = @"mk_bml_receiveLoadStatusChangedNotification";
NSString *const mk_bml_receiveOverloadProtectionValueChangedNotification = @"mk_bml_receiveOverloadProtectionValueChangedNotification";
NSString *const mk_bml_receiveCountdownNotification = @"mk_bml_receiveCountdownNotification";
NSString *const mk_bml_receiveEnergyVCPNotification = @"mk_bml_receiveEnergyVCPNotification";
NSString *const mk_bml_receiveCurrentEnergyNotification = @"mk_bml_receiveCurrentEnergyNotification";

static MKBMLCentralManager *manager = nil;
static dispatch_once_t onceToken;

@interface MKBMLCentralManager ()

@property (nonatomic, assign)mk_bml_centralConnectStatus connectStatus;

@end

@implementation MKBMLCentralManager

- (instancetype)init {
    if (self = [super init]) {
        [[MKBLEBaseCentralManager shared] loadDataManager:self];
    }
    return self;
}

+ (MKBMLCentralManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKBMLCentralManager new];
        }
    });
    return manager;
}

+ (void)sharedDealloc {
    [MKBLEBaseCentralManager singleDealloc];
    manager = nil;
    onceToken = 0;
}

+ (void)removeFromCentralList {
    [[MKBLEBaseCentralManager shared] removeDataManager:manager];
    manager = nil;
    onceToken = 0;
}

#pragma mark - MKBLEBaseScanProtocol
- (void)MKBLEBaseCentralManagerDiscoverPeripheral:(CBPeripheral *)peripheral
                                advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                                             RSSI:(NSNumber *)RSSI {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MKBMLDeviceModel *deviceModel = [self parseDeviceDataWithPeripheral:peripheral
                                                                    advData:advertisementData
                                                                       rssi:RSSI];
        if (!deviceModel) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(mk_bml_receiveDevice:)]) {
                [self.delegate mk_bml_receiveDevice:deviceModel];
            }
        });
    });
}

- (void)MKBLEBaseCentralManagerStartScan {
    if ([self.delegate respondsToSelector:@selector(mk_bml_startScan)]) {
        [self.delegate mk_bml_startScan];
    }
}

- (void)MKBLEBaseCentralManagerStopScan {
    if ([self.delegate respondsToSelector:@selector(mk_bml_stopScan)]) {
        [self.delegate mk_bml_stopScan];
    }
}

#pragma mark - MKBLEBaseCentralManagerStateProtocol
- (void)MKBLEBaseCentralManagerStateChanged:(MKCentralManagerState)centralManagerState {
    NSLog(@"蓝牙中心改变");
    [[NSNotificationCenter defaultCenter] postNotificationName:mk_bml_centralManagerStateChangedNotification object:nil];
}

- (void)MKBLEBasePeripheralConnectStateChanged:(MKPeripheralConnectState)connectState {
    //连接成功的判断必须是发送密码成功之后
    if (connectState == MKPeripheralConnectStateUnknow) {
        self.connectStatus = mk_bml_centralConnectStatusUnknow;
    }else if (connectState == MKPeripheralConnectStateConnecting) {
        self.connectStatus = mk_bml_centralConnectStatusConnecting;
    }else if (connectState == MKPeripheralConnectStateConnected) {
        self.connectStatus = mk_bml_centralConnectStatusConnected;
    }else if (connectState == MKPeripheralConnectStateConnectedFailed) {
        self.connectStatus = mk_bml_centralConnectStatusConnectedFailed;
    }else if (connectState == MKPeripheralConnectStateDisconnect) {
        self.connectStatus = mk_bml_centralConnectStatusDisconnect;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:mk_bml_peripheralConnectStateChangedNotification object:nil];
}

#pragma mark - MKBLEBaseCentralManagerProtocol
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"+++++++++++++++++接收数据出错");
        return;
    }
    NSString *tempData = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
    [MKBLEBaseLogManager saveDataWithFileName:@"/BLELog" dataList:@[[tempData mutableCopy]]];
    if ([characteristic.UUID.UUIDString isEqualToString:@"FFB2"]) {
        //通知
        [self parseFFB2Datas:characteristic];
        return;
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"+++++++++++++++++发送数据出错");
        return;
    }
}

#pragma mark - public method
- (CBCentralManager *)centralManager {
    return [MKBLEBaseCentralManager shared].centralManager;
}

- (CBPeripheral *)peripheral {
    return [MKBLEBaseCentralManager shared].peripheral;
}

- (mk_bml_centralManagerStatus )centralStatus {
    return ([MKBLEBaseCentralManager shared].centralStatus == MKCentralManagerStateEnable)
    ? mk_bml_centralManagerStatusEnable
    : mk_bml_centralManagerStatusUnable;
}

- (void)startScan {
    [[MKBLEBaseCentralManager shared] scanForPeripheralsWithServices:@[] options:nil];
}

- (void)stopScan {
    [[MKBLEBaseCentralManager shared] stopScan];
}

- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
                 sucBlock:(void (^)(CBPeripheral *peripheral))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    if (!peripheral) {
        [MKBLEBaseSDKAdopter operationConnectFailedBlock:failedBlock];
        return;
    }
    MKBMLPeripheral *bmlPeripheral = [[MKBMLPeripheral alloc] initWithPeripheral:peripheral];
    [[MKBLEBaseCentralManager shared] connectDevice:bmlPeripheral
                                           sucBlock:sucBlock
                                        failedBlock:failedBlock];
}

- (void)disconnect {
    [[MKBLEBaseCentralManager shared] disconnect];
}

- (void)addTaskWithTaskID:(mk_bml_taskOperationID)operationID
           characteristic:(CBCharacteristic *)characteristic
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
                 sucBlock:(void (^)(id returnData))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    MKBMLOperation *operation = [self generateOperationWithOperationID:operationID
                                                        characteristic:characteristic
                                                              resetNum:resetNum
                                                           commandData:commandData
                                                              sucBlock:sucBlock
                                                           failedBlock:failedBlock];
    if (!operation) {
        return;
    }
    [[MKBLEBaseCentralManager shared] addOperation:operation];
}

#pragma mark - task method
- (MKBMLOperation <MKBLEBaseOperationProtocol>*)generateOperationWithOperationID:(mk_bml_taskOperationID)operationID
                                                                  characteristic:(CBCharacteristic *)characteristic
                                                                        resetNum:(BOOL)resetNum
                                                                     commandData:(NSString *)commandData
                                                                        sucBlock:(void (^)(id returnData))sucBlock
                                                                     failedBlock:(void (^)(NSError *error))failedBlock{
    if (![[MKBLEBaseCentralManager shared] readyToCommunication]) {
        [self operationFailedBlockWithMsg:@"The current connection device is in disconnect" failedBlock:failedBlock];
        return nil;
    }
    if (!MKValidStr(commandData)) {
        [self operationFailedBlockWithMsg:@"Input parameter error" failedBlock:failedBlock];
        return nil;
    }
    if (!characteristic) {
        [self operationFailedBlockWithMsg:@"Characteristic error" failedBlock:failedBlock];
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    MKBMLOperation <MKBLEBaseOperationProtocol>*operation = [[MKBMLOperation alloc] initOperationWithID:operationID resetNum:resetNum commandBlock:^{
        [[MKBLEBaseCentralManager shared] sendDataToPeripheral:commandData characteristic:characteristic type:CBCharacteristicWriteWithResponse];
    } completeBlock:^(NSError * _Nullable error, id  _Nullable returnData) {
        __strong typeof(self) sself = weakSelf;
        if (error) {
            MKBLEBase_main_safe(^{
                if (failedBlock) {
                    failedBlock(error);
                }
            });
            return ;
        }
        if (!returnData) {
            [sself operationFailedBlockWithMsg:@"Request data error" failedBlock:failedBlock];
            return ;
        }
        NSString *lev = returnData[mk_bml_dataStatusLev];
        if ([lev isEqualToString:@"1"]) {
            //通用无附加信息的
            NSArray *dataList = (NSArray *)returnData[mk_bml_dataInformation];
            if (!dataList) {
                [sself operationFailedBlockWithMsg:@"Request data error" failedBlock:failedBlock];
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":(dataList.count == 1 ? dataList[0] : dataList),
                                        };
            MKBLEBase_main_safe(^{
                if (sucBlock) {
                    sucBlock(resultDic);
                }
            });
            return;
        }
        //对于有附加信息的
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":returnData,
                                    };
        MKBLEBase_main_safe(^{
            if (sucBlock) {
                sucBlock(resultDic);
            }
        });
    }];
    return operation;
}

- (void)operationFailedBlockWithMsg:(NSString *)message failedBlock:(void (^)(NSError *error))failedBlock {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.lifeBLECentralManager"
                                                code:-999
                                            userInfo:@{@"errorInfo":message}];
    MKBLEBase_main_safe(^{
        if (failedBlock) {
            failedBlock(error);
        }
    });
}

#pragma mark - private method

- (MKBMLDeviceModel *)parseDeviceDataWithPeripheral:(CBPeripheral *)peripheral
                                            advData:(NSDictionary *)advertisementData
                                               rssi:(NSNumber *)rssi {
    if ([rssi integerValue] == 127 || !MKValidDict(advertisementData) || !peripheral) {
        return nil;
    }
    NSData *manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey];
    if (manufacturerData.length != 15 && manufacturerData.length != 18) {
        return nil;
    }
    NSString *header = [[MKBLEBaseSDKAdopter hexStringFromData:manufacturerData] substringWithRange:NSMakeRange(0, 4)];
    if (![[header uppercaseString] isEqualToString:@"FF20"]) {
        return nil;
    }
    NSString *content = [[MKBLEBaseSDKAdopter hexStringFromData:manufacturerData] substringFromIndex:4];
    MKBMLDeviceModel *deviceModel = [[MKBMLDeviceModel alloc] init];
    deviceModel.deviceName = advertisementData[CBAdvertisementDataLocalNameKey];
    deviceModel.rssi = [rssi integerValue];
    deviceModel.peripheral = peripheral;
    deviceModel.macAddress = [content substringWithRange:NSMakeRange(0, 4)];
    deviceModel.electronV = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(4, 4)] * 0.1;
    
    if (manufacturerData.length == 15) {
        deviceModel.electronA = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(8, 6)];
        deviceModel.electronP = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(14, 4)] * 0.1;
        
        NSString *state = [MKBLEBaseSDKAdopter binaryByhex:[content substringWithRange:NSMakeRange(24, 2)]];
        deviceModel.loadDetection = [[state substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"];
        deviceModel.overloadState = [[state substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"1"];
        deviceModel.switchStatus = [[state substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"];
    }else if (manufacturerData.length == 18) {
        deviceModel.electronA = [[MKBLEBaseSDKAdopter signedHexTurnString:[content substringWithRange:NSMakeRange(8, 8)]] integerValue];
        deviceModel.electronP = [[MKBLEBaseSDKAdopter signedHexTurnString:[content substringWithRange:NSMakeRange(16, 8)]] integerValue] * 0.1;
        
        NSString *state = [MKBLEBaseSDKAdopter binaryByhex:[content substringWithRange:NSMakeRange(30, 2)]];
        deviceModel.loadDetection = [[state substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"];
        deviceModel.overloadState = [[state substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"1"];
        deviceModel.switchStatus = [[state substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"];
    }
    
    
    return deviceModel;
}

- (void)parseFFB2Datas:(CBCharacteristic *)characteristic {
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
    if (content.length < 8) {
        return;
    }
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b4"]) {
        return;
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    if ([function isEqualToString:@"01"]) {
        //开关状态
        BOOL isOn = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_bml_receiveSwitchStatusChangedNotification
                                                            object:nil
                                                          userInfo:@{@"isOn":@(isOn)}];
        return;
    }
    if ([function isEqualToString:@"02"]) {
        //负载检测
        BOOL loadStatus = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_bml_receiveLoadStatusChangedNotification
                                                            object:nil
                                                          userInfo:@{@"loadStatus":@(loadStatus)}];
        return;
    }
    if ([function isEqualToString:@"03"]) {
        //过载保护
        NSString *value = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)];
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_bml_receiveOverloadProtectionValueChangedNotification
                                                            object:nil
                                                          userInfo:@{@"value":value}];
        return;
    }
    if ([function isEqualToString:@"04"]) {
        //倒计时
        //注意,isOn为倒计时结束后设备翻转的开关状态
        BOOL isOn = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        NSString *configValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 8)];
        NSString *remainingTime = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(16, 8)];
        NSDictionary *dic = @{
                @"isOn":@(isOn),
                @"configValue":configValue,
                @"remainingTime":remainingTime,
            };
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_bml_receiveCountdownNotification
                                                            object:nil
                                                          userInfo:dic];
        return;
    }
    if ([function isEqualToString:@"05"]) {
        //上报当前电压、电流、功率
        NSInteger len = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(4, 2)];
        NSDictionary *dic = [MKBMLAdopter parseVCPValue:[content substringWithRange:NSMakeRange(6, len * 2)]];
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_bml_receiveEnergyVCPNotification
                                                            object:nil
                                                          userInfo:dic];
        return;
    }
    if ([function isEqualToString:@"06"]) {
        //上报当前电能数据
        NSString *year = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)];
        NSString *month = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(10, 2)];
        if (month.length == 1) {
            month = [@"0" stringByAppendingString:month];
        }
        NSString *day = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(12, 2)];
        if (day.length == 1) {
            day = [@"0" stringByAppendingString:day];
        }
        NSString *hour = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(14, 2)];
        if (hour.length == 1) {
            hour = [@"0" stringByAppendingString:hour];
        }
        NSDictionary *dateDic = @{
            @"year":year,
            @"month":month,
            @"day":day,
            @"hour":hour,
        };
        NSString *totalValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(16, 8)];
        NSString *monthlyValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(24, 6)];
        NSString *currentDayValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(30, 6)];
        NSString *currentHourValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(36, 4)];
        NSDictionary *userInfo = @{
            @"date":dateDic,
            @"totalValue":totalValue,
            @"monthlyValue":monthlyValue,
            @"currentDayValue":currentDayValue,
            @"currentHourValue":currentHourValue,
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_bml_receiveCurrentEnergyNotification
                                                            object:nil
                                                          userInfo:userInfo];
        return;
    }
}

@end
