# MokoPlug iOS Software Development Kit Guide

* This SDK support the company’s MokoPlug series products.

# Design instructions

* We divide the communications between SDK and devices into two stages: Scanning stage, Connection stage.For ease of understanding, let’s take a look at the related classes and the relationships between them.：

`MKBMLCentralManager`：Global manager, check system’s bluetooth status, listen status changes, the most important is scan and connect to devices;

`MKBMLDeviceModel`:Instance of devices。

`MKBMLInterface`: When the device is successfully connected, the device data can be read through the interface in `MKBMLInterface.h `；

`MKBMLInterface+MKBMLConfig`: When the device is successfully connected, you can configure the device data through the interface in `MKBMLInterface+MKBMLConfig.h`；


## Scanning Stage

In this stage,`MKBMLCentralManager ` will scan and analyze the advertisement data of MokoPlug devices, MKBMLCentralManager will create `MKBMLDeviceModel ` instance for every physical devices, developers can get all advertisement data by its property.


## Connection Stage

Developers can connect to the device in the following ways:

```
/// Connect device function
/// @param peripheral CBPeripheral
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
                 sucBlock:(void (^)(CBPeripheral *peripheral))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock
```


# Get Started

### Development environment:

* XXcode9+， due to the DFU and Zip Framework based on Swift4.0, so please use Xcode9 or high version to develop;
* iOS12, we limit the minimum iOS system version to 12.0；

### Import to Project

CocoaPods

SDK-BML is available through [CocoaPods](https://cocoapods.org).To install it, simply add the following line to your Podfile, and then import <MKBLEMokoLife/MKBMLSDK.h>：

**pod 'MKBLEMokoLife/SDK-BML'**


*  <font color=#FF0000 face="黑体">!!!on iOS 10 and above, Apple add authority control of bluetooth, you need add the string to "info.plist" file of your project: Privacy - Bluetooth Peripheral Usage Description - "your description". as the screenshot below.</font>

* <font color=#FF0000 face="黑体">!!! In iOS13 and above, Apple added permission restrictions on Bluetooth APi. You need to add a string to the project's info.plist file: Privacy-Bluetooth Always Usage Description-"Your usage description".</font>


## Start Developing

### Get sharedInstance of Manager

First of all, the developer should get the sharedInstance of Manager:

```
MKBMLCentralManager *manager = [MKBMLCentralManager shared];
```

#### 1.Start scanning task to find devices around you,please follow the steps below:

* 1.`manager.delegate = self;` //Set the scan delegate and complete the related delegate methods.
* 2.you can start the scanning task in this way:`[manager startScan];`    
* 3.at the sometime, you can stop the scanning task in this way:`[manager stopScan];`

#### 2.Connect to device

`MKBMLCentralManager `contains the method of connecting the device:

```
/// Connect device function
/// @param peripheral CBPeripheral
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
                 sucBlock:(void (^)(CBPeripheral *peripheral))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;
```

#### 3.Get state

Through the manager, you can get the current Bluetooth status of the mobile phone, the connection status of the device, and the lock status of the device. If you want to monitor the changes of these three states, you can register the following notifications to achieve:

*  When the Bluetooth status of the mobile phone changes，<font color=#FF0000 face="黑体">`mk_bml_centralManagerStateChangedNotification`</font> will be posted.You can get status in this way:

```
[[MKBMLCentralManager shared] centralStatus];
```

*  When the device connection status changes，<font color=#FF0000 face="黑体"> `mk_bml_peripheralConnectStateChangedNotification` </font> will be posted.You can get the status in this way:

```
[MKBMLCentralManager shared].connectState;
```


#### 4.Monitor device data.


*  1.Register for `mk_bml_receiveSwitchStatusChangedNotification` notifications to monitor the switch status of the device.

```

[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchStatusChanged:)
                                                 name: mk_bml_receiveSwitchStatusChangedNotification
                                               object:nil];
                                               
```


```
#pragma mark - Notification
- (void)switchStatusChanged:(NSNotification *)note {
    //
    BOOL isOn = [note.userInfo[@"isOn"] boolValue];
}
```


* 2.Register for `mk_bml_receiveLoadStatusChangedNotification` notifications to monitor whether the equipment is overloaded.

```

[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(overloadStatusChanged:)
                                                 name: mk_bml_receiveLoadStatusChangedNotification
                                               object:nil];
                                               
```


```
#pragma mark - Notification
- (void)overloadStatusChanged:(NSNotification *)note {
    BOOL isOverload = [note.userInfo[@"loadStatus"] boolValue];
}
```

* 3.Register the `mk_bml_receiveCountdownNotification` notification to monitor the countdown status of the device, and the switch status of the device is reversed after the countdown ends.

```

[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCountdownTimerData:)
                                                 name: mk_bml_receiveCountdownNotification
                                               object:nil];
                                               
```


```
#pragma mark - Notification
- (void)receiveCountdownTimerData:(NSNotification *)note {
    /*
     note: @{
@"isOn":@(isOn),//The state of the switch after the countdown is over.
@"configValue":configValue,    //The total time to start the countdown.
@"remainingTime":remainingTime,//Remaining time at the end of the countdown.
     };
     */
}
```

* 4.Register for `mk_bml_receiveEnergyVCPNotification` notification to monitor changes in device voltage, electron current, and work and power.

```

[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(energyVCPNotification:)
                                                 name: mk_bml_receiveEnergyVCPNotification
                                               object:nil];
                                               
```


```
#pragma mark - Notification
- (void)energyVCPNotification:(NSNotification *)note {
    /*
     @"v":@(v),    //v
        @"a":@(a),    //mA
        @"p":@(p)    //w
     */
}
```

* 5.Register the `mk_bml_receiveCurrentEnergyNotification` notification to monitor the energy data stored in the current device.

```

[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCurrentEnergyNotification:)
                                                 name: mk_bml_receiveCurrentEnergyNotification
                                               object:nil];
                                               
```


```
#pragma mark - Notification
- (void)receiveCurrentEnergyNotification:(NSNotification *)note {
    /*
             @"date":dateDic,    //y/m/d/h
            @"totalValue":totalValue,    //Total electric energy.
            @"monthlyValue":monthlyValue,    //Electricity of the month.
            @"currentDayValue":currentDayValue,//Electricity of the day.
            @"currentHourValue":currentHourValue,//Current hour electricity.
     */
}
```


# Change log

* 20210507 first version;
