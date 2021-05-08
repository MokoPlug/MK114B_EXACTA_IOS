//
//  MKBMLEnergyController.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLEnergyController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"

#import "MKBMLEnergyDataModel.h"
#import "MKBMLEnergyDailyTableView.h"
#import "MKBMLEnergyMonthlyTableView.h"

#import "MKBMLCentralManager.h"
#import "MKBMLInterface+MKBMLConfig.h"

#import "MKBMLDeviceInfoController.h"

@interface MKBMLEnergyController ()

@property (nonatomic, strong)UIView *segment;

@property (nonatomic, strong)UIButton *dailyButton;

@property (nonatomic, strong)UIButton *monthlyButton;

@property (nonatomic, assign)NSInteger selectedIndex;

@property (nonatomic, strong)MKBMLEnergyMonthlyTableView *monthTable;

@property (nonatomic, strong)MKBMLEnergyDailyTableView *dailyTable;

@property (nonatomic, strong)MKBMLEnergyDataModel *dataModel;

@end

@implementation MKBMLEnergyController

- (void)dealloc {
    NSLog(@"MKBMLEnergyController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self readEnergyDatas];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetAccumulatedEnergy)
                                                 name:@"mk_bml_resetAccumulatedEnergyNotification"
                                               object:nil];
}

#pragma mark - super method
- (void)leftButtonMethod {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_bml_popToRootViewControllerNotification" object:nil];
}

- (void)rightButtonMethod {
    MKBMLDeviceInfoController *vc = [[MKBMLDeviceInfoController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - event emthod
- (void)dailyButtonPressed {
    if (self.selectedIndex == 0) {
        return;
    }
    self.selectedIndex = 0;
    [self reloadSubViews];
}

- (void)monthlyButtonPressed {
    if (self.selectedIndex == 1) {
        return;
    }
    self.selectedIndex = 1;
    [self reloadSubViews];
}

#pragma mark - note
- (void)resetAccumulatedEnergy {
    //接收到了用户重置电能操作，把所有列表数据清0
    [self.dailyTable resetAllDatas];
    [self.monthTable resetAllDatas];
}

#pragma mark - read data
- (void)readEnergyDatas {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.dataModel startReadEnergyDatasWithScuBlock:^(NSArray * _Nonnull dailyList, NSArray * _Nonnull monthlyList, NSString * _Nonnull pulseConstant, NSString * _Nonnull deviceName) {
        [[MKHudManager share] hide];
        self.defaultTitle = deviceName;
        [self.dailyTable updateEnergyDatas:dailyList pulseConstant:pulseConstant];
        [self.monthTable updateEnergyDatas:monthlyList pulseConstant:pulseConstant];
        
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (void)reloadSubViews {
    UIColor *dailyTitleColor = (self.selectedIndex == 0 ? COLOR_WHITE_MACROS : RGBCOLOR(38,129,255));
    UIColor *monthlyTitleColor = (self.selectedIndex == 1 ? COLOR_WHITE_MACROS : RGBCOLOR(38,129,255));
    UIColor *dailyBackColor = (self.selectedIndex == 0 ? RGBCOLOR(38,129,255) : COLOR_WHITE_MACROS);
    UIColor *monthlyBackColor = (self.selectedIndex == 1 ? RGBCOLOR(38,129,255) : COLOR_WHITE_MACROS);
    [self.dailyButton setTitleColor:dailyTitleColor forState:UIControlStateNormal];
    [self.dailyButton setBackgroundColor:dailyBackColor];
    [self.monthlyButton setTitleColor:monthlyTitleColor forState:UIControlStateNormal];
    [self.monthlyButton setBackgroundColor:monthlyBackColor];
    self.dailyTable.hidden = !(self.selectedIndex == 0);
    self.monthTable.hidden = !(self.selectedIndex == 1);
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = RGBCOLOR(38,129,255);
    [self.rightButton setImage:LOADICON(@"MK114BExacta", @"MKBMLPowerController", @"mk_bml_detailIcon.png") forState:UIControlStateNormal];
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self.view addSubview:self.segment];
    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(240);
        make.top.mas_equalTo(defaultTopInset + 10.f);
        make.height.mas_equalTo(32.f);
    }];
    [self.segment addSubview:self.dailyButton];
    [self.dailyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(self.segment.mas_centerX);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.segment addSubview:self.monthlyButton];
    [self.monthlyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(self.segment.mas_centerX);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.view addSubview:self.monthTable];
    [self.view addSubview:self.dailyTable];
    [self.monthTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.segment.mas_bottom);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 49.f);
    }];
    [self.dailyTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.monthTable);
    }];
}

#pragma mark - getter
- (UIView *)segment {
    if (!_segment) {
        _segment = [[UIView alloc] init];
        _segment.layer.masksToBounds = YES;
        _segment.layer.borderColor = RGBCOLOR(38,129,255).CGColor;
        _segment.layer.borderWidth = 0.5f;
        _segment.layer.cornerRadius = 16.f;
    }
    return _segment;
}

- (UIButton *)dailyButton {
    if (!_dailyButton) {
        _dailyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dailyButton.backgroundColor = RGBCOLOR(38,129,255);
        _dailyButton.titleLabel.font = MKFont(14.f);
        [_dailyButton setTitle:@"Daily" forState:UIControlStateNormal];
        [_dailyButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_dailyButton addTarget:self
                         action:@selector(dailyButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _dailyButton;
}

- (MKBMLEnergyDailyTableView *)dailyTable {
    if (!_dailyTable) {
        _dailyTable = [[MKBMLEnergyDailyTableView alloc] init];
    }
    return _dailyTable;
}

- (UIButton *)monthlyButton {
    if (!_monthlyButton) {
        _monthlyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _monthlyButton.backgroundColor = COLOR_WHITE_MACROS;
        _monthlyButton.titleLabel.font = MKFont(14.f);
        [_monthlyButton setTitle:@"Monthly" forState:UIControlStateNormal];
        [_monthlyButton setTitleColor:RGBCOLOR(38,129,255) forState:UIControlStateNormal];
        [_monthlyButton addTarget:self
                           action:@selector(monthlyButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _monthlyButton;
}

- (MKBMLEnergyMonthlyTableView *)monthTable {
    if (!_monthTable) {
        _monthTable = [[MKBMLEnergyMonthlyTableView alloc] init];
    }
    return _monthTable;
}

- (MKBMLEnergyDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKBMLEnergyDataModel alloc] init];
    }
    return _dataModel;
}

@end
