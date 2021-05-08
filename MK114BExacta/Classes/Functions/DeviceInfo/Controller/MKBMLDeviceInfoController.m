//
//  MKBMLDeviceInfoController.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLDeviceInfoController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKNormalTextCell.h"

#import "MKBMLDeviceInfoModel.h"

@interface MKBMLDeviceInfoController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKBMLDeviceInfoModel *dataModel;

@end

@implementation MKBMLDeviceInfoController

- (void)dealloc {
    NSLog(@"MKBMLDeviceInfoController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self startReadDatas];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKNormalTextCell *cell = [MKNormalTextCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - interface
- (void)startReadDatas {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.dataModel readDataWithSucBlock:^{
        @strongify(self);
        [[MKHudManager share] hide];
        self.defaultTitle = self.dataModel.productName;
        [self loadSectionDatas];
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - load table datas
- (void)loadSectionDatas {
    MKNormalTextCellModel *companyModel = [[MKNormalTextCellModel alloc] init];
    companyModel.leftMsg = @"Company Name";
    companyModel.rightMsg = self.dataModel.companyName;
    [self.dataList addObject:companyModel];
    
    MKNormalTextCellModel *nameModel = [[MKNormalTextCellModel alloc] init];
    nameModel.leftMsg = @"Product Name";
    nameModel.rightMsg = self.dataModel.productName;
    [self.dataList addObject:nameModel];
    
    MKNormalTextCellModel *firmwareModel = [[MKNormalTextCellModel alloc] init];
    firmwareModel.leftMsg = @"Firmware Version";
    firmwareModel.rightMsg = self.dataModel.firmware;
    [self.dataList addObject:firmwareModel];
    
    MKNormalTextCellModel *macModel = [[MKNormalTextCellModel alloc] init];
    macModel.leftMsg = @"Device Mac";
    macModel.rightMsg = self.dataModel.deviceMac;
    [self.dataList addObject:macModel];
    
    [self.tableView reloadData];
}


#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = RGBCOLOR(38,129,255);
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

- (MKBMLDeviceInfoModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKBMLDeviceInfoModel alloc] init];
    }
    return _dataModel;
}

@end
