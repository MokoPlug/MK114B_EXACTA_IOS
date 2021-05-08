//
//  MKBMLSettingsController.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLSettingsController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKTableSectionLineHeader.h"

#import "MKBMLCentralManager.h"
#import "MKBMLInterface+MKBMLConfig.h"

#import "MKBMLSettingDataModel.h"

#import "MKBMLSettingPageCell.h"

#import "MKBMLDeviceInfoController.h"
#import "MKBMLModifyNormalDatasController.h"
#import "MKBMLUpdateController.h"
#import "MKBMLModifyPowerStatusController.h"

@interface MKBMLSettingsController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)NSMutableArray *sectionHeaderList;

@property (nonatomic, strong)MKBMLSettingDataModel *dataModel;

/// 当前present的alert
@property (nonatomic, strong)UIAlertController *currentAlert;

@end

@implementation MKBMLSettingsController

- (void)dealloc {
    NSLog(@"MKBMLSettingsController销毁");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self readDatasFromDevice];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [self addNotifications];
}

#pragma mark - super method
- (void)leftButtonMethod {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_bml_popToRootViewControllerNotification" object:nil];
}

- (void)rightButtonMethod {
    MKBMLDeviceInfoController *vc = [[MKBMLDeviceInfoController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40.f;
    }
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MKTableSectionLineHeader *lineHeader = [MKTableSectionLineHeader initHeaderViewWithTableView:tableView];
    lineHeader.headerModel = self.sectionHeaderList[section];
    return lineHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKBMLSettingPageCellModel *cellModel = nil;
    if (indexPath.section == 0) {
        cellModel = self.section0List[indexPath.row];
    }else if (indexPath.section == 1) {
        cellModel = self.section1List[indexPath.row];
    }
    if (!cellModel) {
        return;
    }
    if (ValidStr(cellModel.methodName) && [self respondsToSelector:NSSelectorFromString(cellModel.methodName)]) {
        [self performSelector:NSSelectorFromString(cellModel.methodName) withObject:nil];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section0List.count;
    }
    return self.section1List.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKBMLSettingPageCell *cell = [MKBMLSettingPageCell initCellWithTableView:tableView];
    if (indexPath.section == 0) {
        cell.dataModel = self.section0List[indexPath.row];
    }else if (indexPath.section == 1) {
        cell.dataModel = self.section1List[indexPath.row];
    }
    return cell;
}

#pragma mark - note
- (void)receiveCurrentEnergyNotification:(NSNotification *)note {
    float tempValue = [note.userInfo[@"totalValue"] floatValue] / [self.dataModel.pulseConstant floatValue];
    MKBMLSettingPageCellModel *energyModel = self.section1List[4];
    energyModel.rightMsg = [NSString stringWithFormat:@"%.2f",tempValue];
}

- (void)dismissAlert {
    if (self.currentAlert && (self.presentedViewController == self.currentAlert)) {
        [self.currentAlert dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - event method
- (void)resetDeviceAlert {
    NSString *msg = @"After reset,the relevant data will be totally cleared,please confirm again.";
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Reset Device"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [self.currentAlert addAction:cancelAction];
    @weakify(self);
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self resetDeviceMethod];
    }];
    [self.currentAlert addAction:moreAction];
    
    [self presentViewController:self.currentAlert animated:YES completion:nil];
}

#pragma mark - interface
- (void)readDatasFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.dataModel readDataWithSucBlock:^{
        @strongify(self);
        [[MKHudManager share] hide];
        [self updateCellDatas];
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)resetEnergyConsumptionMethod {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_resetAccumulatedEnergyWithSucBlock:^{
        [[MKHudManager share] hide];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_bml_resetAccumulatedEnergyNotification"
                                                            object:nil];
        [self readDatasFromDevice];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)resetDeviceMethod {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_resetFactoryWithSucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - cell的点击事件
- (void)pushDeviceNameConfig {
    MKBMLModifyNormalDatasController *vc = [[MKBMLModifyNormalDatasController alloc] init];
    MKBMLModifyNormalDataModel *model = [[MKBMLModifyNormalDataModel alloc] init];
    model.pageType = MKBMLModifyDeviceNamePage;
    model.textFieldValue = self.dataModel.deviceName;
    vc.dataModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configPowerOnStatus {
    MKBMLModifyPowerStatusController *vc = [[MKBMLModifyPowerStatusController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushDFUPage {
    MKBMLUpdateController *vc = [[MKBMLUpdateController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configBroadcastFrequency {
    MKBMLModifyNormalDatasController *vc = [[MKBMLModifyNormalDatasController alloc] init];
    MKBMLModifyNormalDataModel *model = [[MKBMLModifyNormalDataModel alloc] init];
    model.pageType = MKBMLModifyBroadcastFrequencyPage;
    model.textFieldValue = self.dataModel.advInterval;
    vc.dataModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configOverload {
    MKBMLModifyNormalDatasController *vc = [[MKBMLModifyNormalDatasController alloc] init];
    MKBMLModifyNormalDataModel *model = [[MKBMLModifyNormalDataModel alloc] init];
    model.pageType = MKBMLModifyOverloadValuePage;
    model.textFieldValue = self.dataModel.overloadValue;
    vc.dataModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configPowerReportInterval {
    MKBMLModifyNormalDatasController *vc = [[MKBMLModifyNormalDatasController alloc] init];
    MKBMLModifyNormalDataModel *model = [[MKBMLModifyNormalDataModel alloc] init];
    model.pageType = MKBMLModifyPowerReportIntervalPage;
    model.textFieldValue = self.dataModel.powerReInterval;
    vc.dataModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configEnergyReportInterval {
    MKBMLModifyNormalDatasController *vc = [[MKBMLModifyNormalDatasController alloc] init];
    MKBMLModifyNormalDataModel *model = [[MKBMLModifyNormalDataModel alloc] init];
    model.pageType = MKBMLModifyEnergyReportIntervalPage;
    model.textFieldValue = self.dataModel.energyReInterval;
    model.powerValue = self.dataModel.powerChangeNoti;
    vc.dataModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configPowerChangeNotification {
    MKBMLModifyNormalDatasController *vc = [[MKBMLModifyNormalDatasController alloc] init];
    MKBMLModifyNormalDataModel *model = [[MKBMLModifyNormalDataModel alloc] init];
    model.pageType = MKBMLModifyPowerChangeNotificationPage;
    model.textFieldValue = self.dataModel.powerChangeNoti;
    model.powerValue = self.dataModel.energyReInterval;
    vc.dataModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)resetEnergyConsumptionAlert {
    NSString *msg = @"Please confirm again whether to reset the accumulated electricity?Value will be recounted after clearing.";
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Reset Energy Consumption"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [self.currentAlert addAction:cancelAction];
    @weakify(self);
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self resetEnergyConsumptionMethod];
    }];
    [self.currentAlert addAction:moreAction];
    
    [self presentViewController:self.currentAlert animated:YES completion:nil];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    [self loadSection0Datas];
    [self loadSection1Datas];
    [self loadSectionHeaderList];
    
    [self.tableView reloadData];
}

- (void)loadSection0Datas {
    MKBMLSettingPageCellModel *nameModel = [self loadCellModelWithLeftMsg:@"Modify device name"];
    nameModel.methodName = @"pushDeviceNameConfig";
    [self.section0List addObject:nameModel];
    
    MKBMLSettingPageCellModel *powerModel = [self loadCellModelWithLeftMsg:@"Modify power on status"];
    powerModel.methodName = @"configPowerOnStatus";
    [self.section0List addObject:powerModel];
    
    MKBMLSettingPageCellModel *updateModel = [self loadCellModelWithLeftMsg:@"Check update"];
    updateModel.methodName = @"pushDFUPage";
    [self.section0List addObject:updateModel];
}

- (void)loadSection1Datas {
    MKBMLSettingPageCellModel *frequencyModel = [self loadCellModelWithLeftMsg:@"Broadcast frequency(100ms)"];
    frequencyModel.methodName = @"configBroadcastFrequency";
    [self.section1List addObject:frequencyModel];
    
    MKBMLSettingPageCellModel *overloadModel = [self loadCellModelWithLeftMsg:@"Overload value(W)"];
    overloadModel.methodName = @"configOverload";
    [self.section1List addObject:overloadModel];
    
    MKBMLSettingPageCellModel *powerIntervalModel = [self loadCellModelWithLeftMsg:@"Power reporting Interval (sec)"];
    powerIntervalModel.methodName = @"configPowerReportInterval";
    [self.section1List addObject:powerIntervalModel];
    
    MKBMLSettingPageCellModel *energyIntervalModel = [self loadCellModelWithLeftMsg:@"Energy reporting Interval(min)"];
    energyIntervalModel.methodName = @"configEnergyReportInterval";
    [self.section1List addObject:energyIntervalModel];
    
    MKBMLSettingPageCellModel *notificationModel = [self loadCellModelWithLeftMsg:@"Power change notification(%)"];
    notificationModel.methodName = @"configPowerChangeNotification";
    [self.section1List addObject:notificationModel];
    
    MKBMLSettingPageCellModel *energyModel = [self loadCellModelWithLeftMsg:@"Energy consumption(KWh)"];
    energyModel.methodName = @"resetEnergyConsumptionAlert";
    [self.section1List addObject:energyModel];
}

- (void)loadSectionHeaderList {
    MKTableSectionLineHeaderModel *headerModel1 = [[MKTableSectionLineHeaderModel alloc] init];
    headerModel1.contentColor = RGBCOLOR(242, 242, 242);
    headerModel1.msgTextFont = MKFont(12.f);
    headerModel1.msgTextColor = RGBCOLOR(128, 128, 128);
    headerModel1.text = @"General settings";
    [self.sectionHeaderList addObject:headerModel1];
    
    MKTableSectionLineHeaderModel *headerModel2 = [[MKTableSectionLineHeaderModel alloc] init];
    headerModel2.contentColor = RGBCOLOR(242, 242, 242);
    headerModel2.msgTextFont = MKFont(12.f);
    headerModel2.msgTextColor = RGBCOLOR(128, 128, 128);
    headerModel2.text = @"Advanced settings";
    [self.sectionHeaderList addObject:headerModel2];
}

- (MKBMLSettingPageCellModel *)loadCellModelWithLeftMsg:(NSString *)msg {
    MKBMLSettingPageCellModel *cellModel = [[MKBMLSettingPageCellModel alloc] init];
    cellModel.leftMsg = msg;
    return cellModel;
}

- (void)updateCellDatas {
    MKBMLSettingPageCellModel *nameModel = self.section0List[0];
    nameModel.rightMsg = self.dataModel.deviceName;
    
    MKBMLSettingPageCellModel *frequencyModel = self.section1List[0];
    frequencyModel.rightMsg = self.dataModel.advInterval;
    
    MKBMLSettingPageCellModel *overloadModel = self.section1List[1];
    overloadModel.rightMsg = self.dataModel.overloadValue;
    
    MKBMLSettingPageCellModel *powerIntervalModel = self.section1List[2];
    powerIntervalModel.rightMsg = self.dataModel.powerReInterval;
    
    MKBMLSettingPageCellModel *energyIntervalModel = self.section1List[3];
    energyIntervalModel.rightMsg = self.dataModel.energyReInterval;
    
    MKBMLSettingPageCellModel *notificationModel = self.section1List[4];
    notificationModel.rightMsg = self.dataModel.powerChangeNoti;
    
    MKBMLSettingPageCellModel *energyModel = self.section1List[5];
    energyModel.rightMsg = self.dataModel.energyConsumption;
    
    self.defaultTitle = self.dataModel.deviceName;
    
    [self.tableView reloadData];
}

#pragma mark - private method
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCurrentEnergyNotification:)
                                                 name:mk_bml_receiveCurrentEnergyNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissAlert)
                                                 name:@"mk_bml_settingPageNeedDismissAlert"
                                               object:nil];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = RGBCOLOR(38,129,255);
    self.view.backgroundColor = RGBCOLOR(242, 242, 242);
    [self.rightButton setImage:LOADICON(@"MK114BExacta", @"MKBMLPowerController", @"mk_bml_detailIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 49.f);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = RGBCOLOR(242, 242, 242);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [self footerView];
    }
    return _tableView;
}

- (NSMutableArray *)section0List {
    if (!_section0List) {
        _section0List = [NSMutableArray array];
    }
    return _section0List;
}

- (NSMutableArray *)section1List {
    if (!_section1List) {
        _section1List = [NSMutableArray array];
    }
    return _section1List;
}

- (NSMutableArray *)sectionHeaderList {
    if (!_sectionHeaderList) {
        _sectionHeaderList = [NSMutableArray array];
    }
    return _sectionHeaderList;
}

- (MKBMLSettingDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKBMLSettingDataModel alloc] init];
    }
    return _dataModel;
}

- (UIView *)footerView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 100.f)];
    footerView.backgroundColor = RGBCOLOR(242, 242, 242);
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20.f, kViewWidth, 44.f)];
    msgLabel.backgroundColor = COLOR_WHITE_MACROS;
    msgLabel.font = MKFont(13.f);
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.textColor = RGBCOLOR(128, 128, 128);
    msgLabel.text = @"Reset Device";
    [msgLabel addTapAction:self selector:@selector(resetDeviceAlert)];
    [footerView addSubview:msgLabel];
    
    return footerView;
}

@end
