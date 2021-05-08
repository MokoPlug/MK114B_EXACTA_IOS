//
//  MKBMLModifyPowerStatusController.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLModifyPowerStatusController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKNormalTextCell.h"

#import "MKBMLInterface+MKBMLConfig.h"

@interface MKBMLModifyPowerStatusController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

/// 当前选中的状态
@property (nonatomic, assign)NSInteger index;

@end

@implementation MKBMLModifyPowerStatusController

- (void)dealloc {
    NSLog(@"MKBMLModifyPowerStatusController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [self readDataFromDevice];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.index == indexPath.row) {
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_configPowerOnSwitchStatus:indexPath.row sucBlock:^{
        [[MKHudManager share] hide];
        self.index = indexPath.row;
        [self updateCellState];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKNormalTextCell *cell = [MKNormalTextCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - interface
- (void)readDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_readPowerOnSwitchStatusWithSucBlock:^(id  _Nonnull returnData) {
        [[MKHudManager share] hide];
        self.index = [returnData[@"result"][@"switchStatus"] integerValue];
        [self updateCellState];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    MKNormalTextCellModel *offModel = [[MKNormalTextCellModel alloc] init];
    offModel.leftMsg = @"Switch off";
    offModel.leftMsgTextFont = MKFont(14.f);
    [self.dataList addObject:offModel];
    
    MKNormalTextCellModel *onModel = [[MKNormalTextCellModel alloc] init];
    onModel.leftMsg = @"Switch on";
    onModel.leftMsgTextFont = MKFont(14.f);
    [self.dataList addObject:onModel];
    
    MKNormalTextCellModel *lastModel = [[MKNormalTextCellModel alloc] init];
    lastModel.leftMsg = @"Revert to last status";
    lastModel.leftMsgTextFont = MKFont(14.f);
    [self.dataList addObject:lastModel];
    
    [self.tableView reloadData];
}

- (void)updateCellState {
    MKNormalTextCellModel *offModel = self.dataList[0];
    if (self.index == 0) {
        offModel.leftIcon = LOADICON(@"MK114BExacta", @"MKBMLModifyPowerStatusController", @"mk_bml_modifyPowerOnSelectedIcon.png");
        offModel.leftMsgTextColor = RGBCOLOR(38,129,255);
    }else {
        offModel.leftIcon = LOADICON(@"MK114BExacta", @"MKBMLModifyPowerStatusController", @"mk_bml_modifyPowerOnUnselectedIcon.png");
        offModel.leftMsgTextColor = RGBCOLOR(128, 128, 128);
    }
    
    MKNormalTextCellModel *onModel = self.dataList[1];
    if (self.index == 1) {
        onModel.leftIcon = LOADICON(@"MK114BExacta", @"MKBMLModifyPowerStatusController", @"mk_bml_modifyPowerOnSelectedIcon.png");
        onModel.leftMsgTextColor = RGBCOLOR(38,129,255);
    }else {
        onModel.leftIcon = LOADICON(@"MK114BExacta", @"MKBMLModifyPowerStatusController", @"mk_bml_modifyPowerOnUnselectedIcon.png");
        onModel.leftMsgTextColor = RGBCOLOR(128, 128, 128);
    }
    
    MKNormalTextCellModel *lastModel = self.dataList[2];
    if (self.index == 2) {
        lastModel.leftIcon = LOADICON(@"MK114BExacta", @"MKBMLModifyPowerStatusController", @"mk_bml_modifyPowerOnSelectedIcon.png");
        lastModel.leftMsgTextColor = RGBCOLOR(38,129,255);
    }else {
        lastModel.leftIcon = LOADICON(@"MK114BExacta", @"MKBMLModifyPowerStatusController", @"mk_bml_modifyPowerOnUnselectedIcon.png");
        lastModel.leftMsgTextColor = RGBCOLOR(128, 128, 128);
    }
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = RGBCOLOR(38,129,255);
    self.defaultTitle = @"Modify power on status";
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
