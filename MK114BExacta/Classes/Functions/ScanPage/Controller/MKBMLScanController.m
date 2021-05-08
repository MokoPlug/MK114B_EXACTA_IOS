//
//  MKBMLScanController.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/30.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLScanController.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "Masonry.h"

#import "UIViewController+HHTransition.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "NSObject+MKModel.h"

#import "MKHudManager.h"
#import "MKCustomUIAdopter.h"

#import "MKBMLSDK.h"

#import "MKBMLScanFilterView.h"
#import "MKBMLScanSearchButton.h"
#import "MKBMLScanPageCell.h"

#import "MKBMLAboutController.h"
#import "MKBMLTabBarController.h"

static CGFloat const offset_X = 15.f;
static CGFloat const searchButtonHeight = 40.f;
static CGFloat const headerViewHeight = 90.f;

static NSTimeInterval const kRefreshInterval = 0.5f;

@interface MKBMLConfigDeviceDateModel : NSObject<MKBMLDeviceTimeProtocol>

@property (nonatomic, assign)NSInteger year;

@property (nonatomic, assign)NSInteger month;

@property (nonatomic, assign)NSInteger day;

@property (nonatomic, assign)NSInteger hour;

@property (nonatomic, assign)NSInteger minutes;

@property (nonatomic, assign)NSInteger second;

@end

@implementation MKBMLConfigDeviceDateModel
@end

@interface MKBMLScanController ()<UITableViewDelegate,
UITableViewDataSource,
mk_bml_centralManagerScanDelegate,
MKBMLSearchButtonDelegate,
MKBMLTabBarControllerDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKBMLSearchButtonModel *buttonModel;

@property (nonatomic, strong)MKBMLScanSearchButton *searchButton;

@property (nonatomic, strong)UIImageView *refreshIcon;

@property (nonatomic, strong)dispatch_source_t scanTimer;

/// 定时刷新
@property (nonatomic, assign)CFRunLoopObserverRef observerRef;
//扫描到新的设备不能立即刷新列表，降低刷新频率
@property (nonatomic, assign)BOOL isNeedRefresh;

@property (nonatomic, strong)NSMutableDictionary *identifyCache;

@end

@implementation MKBMLScanController

- (void)dealloc {
    NSLog(@"MKBMLScanController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //移除runloop的监听
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), self.observerRef, kCFRunLoopCommonModes);
    [[MKBMLCentralManager shared] stopScan];
    [MKBMLCentralManager removeFromCentralList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self startRefresh];
}

#pragma mark - super method
- (void)leftButtonMethod {
    if ([MKBMLCentralManager shared].centralStatus != mk_bml_centralManagerStatusEnable) {
        [self.view showCentralToast:@"The current system of bluetooth is not available!"];
        return;
    }
    self.leftButton.selected = !self.leftButton.selected;
    [self.refreshIcon.layer removeAnimationForKey:@"mk_refreshAnimationKey"];
    if (!self.leftButton.isSelected) {
        //停止扫描
        [[MKBMLCentralManager shared] stopScan];
        if (self.scanTimer) {
            dispatch_cancel(self.scanTimer);
        }
        return;
    }
    [self.identifyCache removeAllObjects];
    [self.dataList removeAllObjects];
    [self.tableView reloadData];
    [self.refreshIcon.layer addAnimation:[MKCustomUIAdopter refreshAnimation:2.f] forKey:@"mk_refreshAnimationKey"];
    [self scanTimerRun];
}

- (void)rightButtonMethod {
    MKBMLAboutController *vc = [[MKBMLAboutController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKBMLScanPageCell *cell = [MKBMLScanPageCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self connectDeviceWithIndex:indexPath.row];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.f;
}

#pragma mark - MKBMLSearchButtonDelegate
- (void)bml_scanSearchButtonMethod {
    [MKBMLScanFilterView showSearchKey:self.buttonModel.searchName
                                  rssi:self.buttonModel.searchRssi
                               minRssi:self.buttonModel.minSearchRssi
                           searchBlock:^(NSString * _Nonnull searchKey, NSInteger searchRssi) {
        self.buttonModel.searchRssi = searchRssi;
        self.buttonModel.searchName = searchKey;
        self.searchButton.dataModel = self.buttonModel;
        
        self.leftButton.selected = NO;
        [self leftButtonMethod];
    }];
}

- (void)bml_scanSearchButtonClearMethod {
    self.buttonModel.searchRssi = -100;
    self.buttonModel.searchName = @"";
    self.leftButton.selected = NO;
    [self leftButtonMethod];
}

#pragma mark - mk_bml_centralManagerScanDelegate
- (void)mk_bml_receiveDevice:(MKBMLDeviceModel *)deviceModel {
    [self updateDataWithDeviceModel:deviceModel];
}

- (void)mk_bml_stopScan {
    //如果是左上角在动画，则停止动画
    if (self.leftButton.isSelected) {
        [self.refreshIcon.layer removeAnimationForKey:@"mk_refreshAnimationKey"];
        [self.leftButton setSelected:NO];
    }
}

#pragma mark - MKBMLTabBarControllerDelegate
- (void)mk_bml_needResetScanDelegate:(BOOL)need {
    if (need) {
        [MKBMLCentralManager shared].delegate = self;
    }
    [self performSelector:@selector(startScanDevice) withObject:nil afterDelay:(need ? 1.f : 0.1f)];
}

#pragma mark - notice method
- (void)showCentralStatus{
    if ([MKBMLCentralManager shared].centralStatus != mk_bml_centralManagerStatusEnable) {
        NSString *msg = @"The current system of bluetooth is not available!";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Dismiss"
                                                                                 message:msg
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:moreAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [self leftButtonMethod];
}

#pragma mark - 刷新
- (void)startScanDevice {
    self.leftButton.selected = NO;
    [self leftButtonMethod];
}

- (void)scanTimerRun{
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    [[MKBMLCentralManager shared] startScan];
    self.scanTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 60 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.scanTimer, start, interval, 0);
    @weakify(self);
    dispatch_source_set_event_handler(self.scanTimer, ^{
        @strongify(self);
        [[MKBMLCentralManager shared] stopScan];
        [self needRefreshList];
    });
    dispatch_resume(self.scanTimer);
}

- (void)needRefreshList {
    //标记需要刷新
    self.isNeedRefresh = YES;
    //唤醒runloop
    CFRunLoopWakeUp(CFRunLoopGetMain());
}

- (void)runloopObserver {
    @weakify(self);
    __block NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    self.observerRef = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        @strongify(self);
        if (activity == kCFRunLoopBeforeWaiting) {
            //runloop空闲的时候刷新需要处理的列表,但是需要控制刷新频率
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            if (currentInterval - timeInterval < kRefreshInterval) {
                return;
            }
            timeInterval = currentInterval;
            if (self.isNeedRefresh) {
                [self.tableView reloadData];
                self.isNeedRefresh = NO;
            }
        }
    });
    //添加监听，模式为kCFRunLoopCommonModes
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), self.observerRef, kCFRunLoopCommonModes);
}

- (void)updateDataWithDeviceModel:(MKBMLDeviceModel *)deviceModel{
    if (ValidStr(self.buttonModel.searchName)) {
        //如果打开了过滤，先看是否需要过滤设备名字
        if (deviceModel.rssi >= self.buttonModel.searchRssi && [[deviceModel.deviceName uppercaseString] containsString:[self.buttonModel.searchName uppercaseString]]) {
            [self processDevice:deviceModel];
        }
        return;
    }
    if (self.buttonModel.searchRssi > self.buttonModel.minSearchRssi) {
        //开启rssi过滤
        if (deviceModel.rssi >= self.buttonModel.searchRssi) {
            [self processDevice:deviceModel];
        }
        return;
    }
    [self processDevice:deviceModel];
}

- (void)processDevice:(MKBMLDeviceModel *)deviceModel{
    //查看数据源中是否已经存在相关设备
    NSString *identy = deviceModel.peripheral.identifier.UUIDString;
    
    BOOL contain = [self.identifyCache[identy] boolValue];
    if (contain) {
        //如果是已经存在了，替换
        [self deviceExistDataSource:deviceModel];
        return;
    }
    //不存在，则加入
    [self.dataList addObject:deviceModel];
    [self.identifyCache setValue:@(YES) forKey:deviceModel.peripheral.identifier.UUIDString];
    [self needRefreshList];
}

- (void)deviceExistDataSource:(MKBMLDeviceModel *)deviceModel {
    NSArray *tempList = [NSArray arrayWithArray:self.dataList];
    NSInteger currentIndex = 0;
    for (NSInteger i = 0; i < tempList.count; i ++) {
        MKBMLDeviceModel *model = tempList[i];
        if ([model.peripheral.identifier.UUIDString isEqualToString:deviceModel.peripheral.identifier.UUIDString]) {
            currentIndex = i;
            break;
        }
    }
    [self.dataList replaceObjectAtIndex:currentIndex withObject:deviceModel];
    [self needRefreshList];
}

#pragma mark - 连接设备
- (void)connectDeviceWithIndex:(NSInteger)index {
    MKBMLDeviceModel *deviceModel = self.dataList[index];
    //停止扫描
    [self.refreshIcon.layer removeAnimationForKey:@"mk_refreshAnimationKey"];
    [[MKBMLCentralManager shared] stopScan];
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    [[MKHudManager share] showHUDWithTitle:@"Connecting..." inView:self.view isPenetration:NO];
    [[MKBMLCentralManager shared] connectPeripheral:deviceModel.peripheral sucBlock:^(CBPeripheral * _Nonnull peripheral) {
        [[MKHudManager share] hide];
        [self configDeviceTime];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self connectFailed];
    }];
}

- (void)configDeviceTime {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    MKBMLConfigDeviceDateModel *dateModel = [[MKBMLConfigDeviceDateModel alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    NSArray *dateList = [dateString componentsSeparatedByString:@"-"];
    dateModel.year = [dateList[0] integerValue];
    dateModel.month = [dateList[1] integerValue];
    dateModel.day = [dateList[2] integerValue];
    dateModel.hour = [dateList[3] integerValue];
    dateModel.minutes = [dateList[4] integerValue];
    dateModel.second = [dateList[5] integerValue];
    [MKBMLInterface bml_configDeviceTime:dateModel sucBlock:^{
        [[MKHudManager share] hide];
        [self performSelector:@selector(pushTabBarPage) withObject:nil afterDelay:0.3f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self connectFailed];
    }];
}

- (void)pushTabBarPage {
    MKBMLTabBarController *vc = [[MKBMLTabBarController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    @weakify(self);
    [self hh_presentViewController:vc presentStyle:HHPresentStyleErected completion:^{
        @strongify(self);
        vc.delegate = self;
    }];
}

- (void)connectFailed {
    self.leftButton.selected = NO;
    [self leftButtonMethod];
}

#pragma mark -
- (void)startRefresh {
    self.searchButton.dataModel = self.buttonModel;
    [self runloopObserver];
    [MKBMLCentralManager shared].delegate = self;
    //此处延时3.5s，与启动页加载3.5s对应，另外第一次安装的时候有蓝牙弹窗授权，也需要延时用来防止出现获取权限的时候出现蓝牙未打开的情况。
    //新的业务需求，第一次安装app的时候，需要用户手动点击左上角开启扫描，后面每次需要自动开启扫描     20210413
    NSNumber *install = [[NSUserDefaults standardUserDefaults] objectForKey:@"mk_bml_installedKey"];
    if (!ValidNum(install) || ![install boolValue]) {
        //第一次安装
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"mk_bml_installedKey"];
        return;
    }
    [self performSelector:@selector(showCentralStatus) withObject:nil afterDelay:3.5f];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = RGBCOLOR(38,129,255);
    [self.view setBackgroundColor:RGBCOLOR(245, 245, 245)];
    [self.rightButton setImage:LOADICON(@"MK114BExacta", @"MKBMLScanController", @"mk_bml_scanRightAboutIcon.png") forState:UIControlStateNormal];
    self.titleLabel.text = @"Moko Plug";
    [self.leftButton setImage:nil forState:UIControlStateNormal];
    [self.leftButton addSubview:self.refreshIcon];
    [self.refreshIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.leftButton.mas_centerX);
        make.width.mas_equalTo(22.f);
        make.centerY.mas_equalTo(self.leftButton.mas_centerY);
        make.height.mas_equalTo(22.f);
    }];
    UIView *headerView = [[UIView alloc] init];
    
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(defaultTopInset);
        make.height.mas_equalTo(searchButtonHeight + 2 * offset_X);
    }];
    
    [headerView addSubview:self.searchButton];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(offset_X);
        make.height.mas_equalTo(searchButtonHeight);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10.f);
        make.top.mas_equalTo(headerView.mas_bottom);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = RGBCOLOR(245, 245, 245);
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIImageView *)refreshIcon {
    if (!_refreshIcon) {
        _refreshIcon = [[UIImageView alloc] init];
        _refreshIcon.image = LOADICON(@"MK114BExacta", @"MKBMLScanController", @"mk_bml_scanRefresh.png");
    }
    return _refreshIcon;
}

- (MKBMLScanSearchButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [[MKBMLScanSearchButton alloc] init];
        _searchButton.delegate = self;
    }
    return _searchButton;
}

- (MKBMLSearchButtonModel *)buttonModel {
    if (!_buttonModel) {
        _buttonModel = [[MKBMLSearchButtonModel alloc] init];
        _buttonModel.placeholder = @"Edit Filter";
        _buttonModel.minSearchRssi = -100;
        _buttonModel.searchRssi = -100;
    }
    return _buttonModel;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableDictionary *)identifyCache {
    if (!_identifyCache) {
        _identifyCache = [NSMutableDictionary dictionary];
    }
    return _identifyCache;
}

@end
