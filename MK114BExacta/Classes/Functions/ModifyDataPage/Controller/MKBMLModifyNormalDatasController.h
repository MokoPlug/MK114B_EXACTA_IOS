//
//  MKBMLModifyNormalDatasController.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MKBMLModifyPageType) {
    MKBMLModifyDeviceNamePage,                  //修改设备名称
    MKBMLModifyBroadcastFrequencyPage,          //修改广播周期
    MKBMLModifyOverloadValuePage,               //修改过载保护
    MKBMLModifyEnergyReportIntervalPage,         //修改存储电能时间间隔
    MKBMLModifyPowerChangeNotificationPage,     //修改电能变化值
    MKBMLModifyPowerReportIntervalPage,         //修改电压电流上报间隔
};

@interface MKBMLModifyNormalDataModel : NSObject

/// 当前页面是设置哪个参数的
@property (nonatomic, assign)MKBMLModifyPageType pageType;

/// 当前参数值
@property (nonatomic, copy)NSString *textFieldValue;

/// 对于累计电能存储参数设置的时候需要知道存储时间间隔和电能变化值，所以当MKBMLModifyEnergyReportIntervalPage这种情况，需要把energyValue传过来，MKBMLModifyPowerChangeNotificationPage需要把存储时间间隔传过来
@property (nonatomic, copy)NSString *powerValue;

@end

@interface MKBMLModifyNormalDatasController : MKBaseViewController

@property (nonatomic, strong)MKBMLModifyNormalDataModel *dataModel;

@end

NS_ASSUME_NONNULL_END
