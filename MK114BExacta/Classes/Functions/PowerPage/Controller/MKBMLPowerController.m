//
//  MKBMLPowerController.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLPowerController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"

#import "MKBMLPowerDataModel.h"
#import "MKBMLPowerCircleView.h"

#import "MKBMLCentralManager.h"
#import "MKBMLInterface+MKBMLConfig.h"

#import "MKBMLDeviceInfoController.h"

static CGFloat const circleView_offset_X = 30.f;
static CGFloat const buttonWidth = 120.f;
static CGFloat const buttonHeight = 32.f;

@interface MKBMLPowerController ()

@property (nonatomic, strong)MKBMLPowerCircleView *circleView;

@property (nonatomic, strong)UIButton *statusButton;

@property (nonatomic, strong)UILabel *overLoadLabel;

@property (nonatomic, strong)MKBMLPowerDataModel *dataModel;

@end

@implementation MKBMLPowerController

- (void)dealloc {
    NSLog(@"MKBMLPowerController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startReadDatas];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
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

#pragma mark - notes
- (void)switchStatusChanged:(NSNotification *)note {
    self.statusButton.selected = [note.userInfo[@"isOn"] boolValue];
    [self reloadStatus];
}

- (void)overloadProtection:(NSNotification *)note {
    self.dataModel.overload = YES;
    [self reloadStatus];
}

- (void)energyVCPNotification:(NSNotification *)note {
    self.dataModel.energyPower = [note.userInfo[@"p"] floatValue];
    [self reloadPowerValue];
}

- (void)overloadStatusChanged:(NSNotification *)note {
    BOOL isOverload = [note.userInfo[@"loadStatus"] boolValue];
    if (isOverload) {
        [self.view showCentralToast:@"LOAD INSERTION"];
    }
}

#pragma mark - event method
- (void)statusButtonPressed {
    BOOL isOn = self.statusButton.selected;
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_configSwitchStatus:!isOn sucBlock:^{
        [[MKHudManager share] hide];
        self.statusButton.selected = !isOn;
        [self reloadStatus];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - interface
- (void)startReadDatas {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.dataModel readDataWithSucBlock:^{
        @strongify(self);
        [[MKHudManager share] hide];
        [self updateDataStates];
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (void)updateDataStates {
    self.defaultTitle = self.dataModel.deviceName;
    self.statusButton.selected = self.dataModel.switchIsOn;
    [self reloadStatus];
    [self reloadPowerValue];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchStatusChanged:)
                                                 name:mk_bml_receiveSwitchStatusChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(overloadProtection:)
                                                 name:mk_bml_receiveOverloadProtectionValueChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(energyVCPNotification:)
                                                 name:mk_bml_receiveEnergyVCPNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(overloadStatusChanged:)
                                                 name:mk_bml_receiveLoadStatusChangedNotification
                                               object:nil];
}

- (void)reloadStatus {
    self.overLoadLabel.hidden = !self.dataModel.overload;
    if (self.dataModel.overload) {
        //过载
        self.statusButton.enabled = NO;
        [self.statusButton setBackgroundColor:RGBCOLOR(217, 217, 217)];
        [self.statusButton setTitle:@"OFF" forState:UIControlStateNormal];
        [self.statusButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        return;
    }
    //正常状态
    NSString *buttonTitle = (self.statusButton.selected ? @"ON" : @"OFF");
    UIColor *backColor = (self.statusButton.selected ? RGBCOLOR(38,129,255) : COLOR_WHITE_MACROS);
    UIColor *titleColor = (self.statusButton.selected ? COLOR_WHITE_MACROS : RGBCOLOR(38,129,255));
    [self.statusButton setTitleColor:titleColor forState:UIControlStateNormal];
    [self.statusButton setTitle:buttonTitle forState:UIControlStateNormal];
    [self.statusButton setBackgroundColor:backColor];
}

- (void)reloadPowerValue {
    [self.circleView updatePowerValues:self.dataModel.energyPower];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = RGBCOLOR(38,129,255);
    self.view.backgroundColor = RGBCOLOR(242, 242, 242);
    [self.rightButton setImage:LOADICON(@"MK114BExacta", @"MKBMLPowerController", @"mk_bml_detailIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.circleView];
    [self.view addSubview:self.statusButton];
    [self.view addSubview:self.overLoadLabel];
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.circleView.mas_bottom).mas_offset(20.f);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
    }];
    [self.overLoadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.statusButton.mas_bottom).mas_offset(16.f);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
    }];
}

#pragma mark - getter
- (MKBMLPowerCircleView *)circleView {
    if (!_circleView) {
        _circleView = [[MKBMLPowerCircleView alloc] initWithFrame:CGRectMake(circleView_offset_X,
                                                                             defaultTopInset + 60.f,
                                                                             kViewWidth - 2 * circleView_offset_X,
                                                                             kViewWidth - 2 * circleView_offset_X)];
    }
    return _circleView;
}

- (UIButton *)statusButton {
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _statusButton.layer.masksToBounds = YES;
        _statusButton.layer.cornerRadius = 14.f;
        [_statusButton addTapAction:self selector:@selector(statusButtonPressed)];
    }
    return _statusButton;
}

- (UILabel *)overLoadLabel {
    if (!_overLoadLabel) {
        _overLoadLabel = [[UILabel alloc] init];
        _overLoadLabel.textColor = RGBCOLOR(120, 120, 120);
        _overLoadLabel.textAlignment = NSTextAlignmentCenter;
        _overLoadLabel.font = MKFont(15.f);
        _overLoadLabel.text = @"Overload";
    }
    return _overLoadLabel;
}

- (MKBMLPowerDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKBMLPowerDataModel alloc] init];
    }
    return _dataModel;
}

@end
