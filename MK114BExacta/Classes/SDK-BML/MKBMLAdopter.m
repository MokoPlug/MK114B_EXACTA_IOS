//
//  MKBMLAdopter.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/29.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLAdopter.h"

#import "MKBLEBaseSDKAdopter.h"

@implementation MKBMLAdopter

+ (NSDictionary *)parseVCPValue:(NSString *)value {
    if (value.length != 14 && value.length != 20) {
        return @{};
    }
    CGFloat v = [MKBLEBaseSDKAdopter getDecimalWithHex:value range:NSMakeRange(0, 4)] * 0.1;
    NSInteger a = 0;
    float p = 0;
    if (value.length == 14) {
        a = [MKBLEBaseSDKAdopter getDecimalWithHex:value range:NSMakeRange(4, 6)];
        p = [MKBLEBaseSDKAdopter getDecimalWithHex:value range:NSMakeRange(10, 4)] * 0.1;
    }else if (value.length == 20) {
        a = [[MKBLEBaseSDKAdopter signedHexTurnString:[value substringWithRange:NSMakeRange(4, 8)]] integerValue];
        p = [[MKBLEBaseSDKAdopter signedHexTurnString:[value substringWithRange:NSMakeRange(12, 8)]] integerValue] * 0.1;
    }
    return @{
        @"v":@(v),
        @"a":@(a),
        @"p":@(p)
    };
}

+ (NSArray *)parseHistoricalEnergy:(NSString *)content {
    NSInteger number = content.length / 8;
    NSMutableArray *dataList = [NSMutableArray array];
    for (NSInteger i = 0; i < number; i ++) {
        NSString *subContent = [content substringWithRange:NSMakeRange(i * 8, 8)];
        NSString *index = [MKBLEBaseSDKAdopter getDecimalStringWithHex:subContent range:NSMakeRange(0, 2)];
        NSString *rotationsNumber = [MKBLEBaseSDKAdopter getDecimalStringWithHex:subContent range:NSMakeRange(2, 6)];
        NSDictionary *dic = @{
            @"index":index,
            @"rotationsNumber":rotationsNumber
        };
        [dataList addObject:dic];
    }
    return dataList;
}

+ (NSArray *)parseEnergyOfToday:(NSString *)content {
    NSInteger number = content.length / 6;
    NSMutableArray *dataList = [NSMutableArray array];
    for (NSInteger i = 0; i < number; i ++) {
        NSString *subContent = [content substringWithRange:NSMakeRange(i * 6, 6)];
        NSString *index = [MKBLEBaseSDKAdopter getDecimalStringWithHex:subContent range:NSMakeRange(0, 2)];
        NSString *rotationsNumber = [MKBLEBaseSDKAdopter getDecimalStringWithHex:subContent range:NSMakeRange(2, 4)];
        NSDictionary *dic = @{
            @"index":index,
            @"rotationsNumber":rotationsNumber
        };
        [dataList addObject:dic];
    }
    return dataList;
}

@end
