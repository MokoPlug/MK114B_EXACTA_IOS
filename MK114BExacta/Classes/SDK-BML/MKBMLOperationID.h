
typedef NS_ENUM(NSInteger, mk_bml_taskOperationID) {
    mk_bml_defaultTaskOperationID,
    
#pragma mark - 读取
    mk_bml_taskReadDeviceNameOperation,
    mk_bml_taskReadAdvIntervalOperation,
    mk_bml_taskReadSwitchStatusOperation,
    mk_bml_taskReadPowerOnSwitchStatusOperation,
    mk_bml_taskReadLoadStatusOperation,
    mk_bml_taskReadOverloadProtectionValueOperation,
    mk_bml_taskReadVCPValueOperation,
    mk_bml_taskReadAccumulatedEnergyOperation,
    mk_bml_taskReadCountdownValueOperation,
    mk_bml_taskReadFirmwareVersionOperation,
    mk_bml_taskReadMacAddressOperation,
    mk_bml_taskReadEnergyStorageParametersOperation,
    mk_bml_taskReadHistoricalEnergyOperation,
    mk_bml_taskReadOverLoadStatusOperation,
    mk_bml_taskReadEnergyDataOfTodayOperation,
    mk_bml_taskReadPulseConstantOperation,
    mk_bml_taskReadVCReportIntervalOperation,
    
#pragma mark - 设置
    mk_bml_taskConfigDeviceNameOperation,
    mk_bml_taskConfigAdvIntervalOperation,
    mk_bml_taskConfigSwitchStatusOperation,
    mk_bml_taskConfigPowerOnSwitchStatusOperation,
    mk_bml_taskConfigOverloadProtectionValueOperation,
    mk_bml_taskResetAccumulatedEnergyOperation,
    mk_bml_taskConfigCountdownValueOperation,
    mk_bml_taskResetFactoryOperation,
    mk_bml_taskConfigEnergyStorageParametersOperation,
    mk_bml_taskConfigDeviceDateOperation,
    mk_bml_taskConfigVCReportIntervalOperation,
};
