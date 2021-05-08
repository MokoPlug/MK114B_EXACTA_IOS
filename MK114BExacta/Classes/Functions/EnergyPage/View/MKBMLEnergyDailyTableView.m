//
//  MKBMLEnergyDailyTableView.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLEnergyDailyTableView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"

#import "MKNormalTextCell.h"

#import "MKBMLEnergyTableHeaderView.h"

#import "MKBMLCentralManager.h"

@interface MKBMLEnergyDailyTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *dailyTableView;

@property (nonatomic, strong)MKBMLEnergyTableHeaderView *dailyTableHeader;

@property (nonatomic, strong)MKBMLEnergyTableHeaderViewModel *dailyHeaderModel;

@property (nonatomic, strong)NSMutableArray *dailyList;

@property (nonatomic, assign)CGFloat pulseConstant;

@end

@implementation MKBMLEnergyDailyTableView

- (void)dealloc {
    NSLog(@"MKBMLEnergyDailyTableView销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:mk_bml_receiveCurrentEnergyNotification
                                                  object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.dailyTableView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveCurrentEnergyNotification:)
                                                     name:mk_bml_receiveCurrentEnergyNotification
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.dailyTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dailyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKNormalTextCell *cell = [MKNormalTextCell initCellWithTableView:tableView];
    cell.dataModel = self.dailyList[indexPath.row];
    return cell;
}

#pragma mark - note
- (void)receiveCurrentEnergyNotification:(NSNotification *)note {
    NSString *hour = note.userInfo[@"date"][@"hour"];
    if (self.dailyList.count == 0) {
        //没有直接添加
        MKNormalTextCellModel *newModel = [self loadCellModelWithLeftMsg:hour rightMsg:note.userInfo[@"currentHourValue"]];
        [self.dailyList addObject:newModel];
    }else {
        BOOL contain = NO;
        for (NSInteger i = 0; i < self.dailyList.count; i ++) {
            MKNormalTextCellModel *model = self.dailyList[i];
            if ([model.leftMsg isEqualToString:hour]) {
                //存在，替换
                model.rightMsg = note.userInfo[@"currentHourValue"];
                contain = YES;
                break;
            }
        }
        if (!contain) {
            //没有，添加
            MKNormalTextCellModel *newModel = [self loadCellModelWithLeftMsg:hour rightMsg:note.userInfo[@"currentHourValue"]];
        }
    }
    [self.dailyTableView reloadData];
    [self reloadHeaderViewWithEnergy:[note.userInfo[@"currentDayValue"] floatValue]];
}

#pragma mark - public method

- (void)updateEnergyDatas:(NSArray *)energyList pulseConstant:(NSString *)pulseConstant {
    self.pulseConstant = [pulseConstant floatValue];
    if (self.pulseConstant == 0 || energyList.count == 0) {
        return;
    }
    [self.dailyList removeAllObjects];
    NSUInteger totalValue = 0;
    for (NSInteger i = energyList.count - 1; i >= 0; i --) {
        NSDictionary *dic = energyList[i];
        NSString *tempIndex = dic[@"index"];
        NSString *leftMsg = (tempIndex.length == 1 ? [@"0" stringByAppendingString:tempIndex] : tempIndex);
        NSString *rightMsg = dic[@"rotationsNumber"];
        totalValue += [dic[@"rotationsNumber"] integerValue];
        MKNormalTextCellModel *model = [self loadCellModelWithLeftMsg:leftMsg rightMsg:rightMsg];
        [self.dailyList addObject:model];
    }
    [self.dailyTableView reloadData];
    [self reloadHeaderViewWithEnergy:(totalValue * 1.f)];
}

- (void)resetAllDatas {
    [self.dailyList removeAllObjects];
    [self.dailyTableView reloadData];
    self.dailyHeaderModel.energyValue = @"0.0";
    self.dailyHeaderModel.dateMsg = [NSString stringWithFormat:@"00:00 to 00:00,%@",[self fetchCurrentDate]];
    [self.dailyTableHeader setDataModel:self.dailyHeaderModel];
}

#pragma mark - private method
- (void)reloadHeaderViewWithEnergy:(float)energy {
    self.dailyHeaderModel.energyValue = [NSString stringWithFormat:@"%.2f",energy / self.pulseConstant];
    NSString *date = [self fetchCurrentDate];
    NSString *tempHour = @"00";
    if (self.dailyList.count > 0) {
        MKNormalTextCellModel *model = self.dailyList.firstObject;
        tempHour = model.leftMsg;
    }
    self.dailyHeaderModel.dateMsg = [NSString stringWithFormat:@"00:00 to %@:00,%@",tempHour,date];
    [self.dailyTableHeader setDataModel:self.dailyHeaderModel];
}

- (MKNormalTextCellModel *)loadCellModelWithLeftMsg:(NSString *)leftMsg rightMsg:(NSString *)rightMsg {
    MKNormalTextCellModel *cellModel = [[MKNormalTextCellModel alloc] init];
    cellModel.leftMsgTextFont = MKFont(14.f);
    cellModel.leftMsgTextColor = RGBCOLOR(128, 128, 128);
    cellModel.leftMsg = leftMsg;
    cellModel.rightMsgTextFont = MKFont(14.f);
    cellModel.rightMsgTextColor = DEFAULT_TEXT_COLOR;
    cellModel.rightMsg = rightMsg;
    return cellModel;
}

#pragma mark - getter
- (MKBaseTableView *)dailyTableView {
    if (!_dailyTableView) {
        _dailyTableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _dailyTableView.backgroundColor = COLOR_WHITE_MACROS;
        _dailyTableView.delegate = self;
        _dailyTableView.dataSource = self;
        _dailyTableView.tableHeaderView = self.dailyTableHeader;
    }
    return _dailyTableView;
}

- (NSMutableArray *)dailyList {
    if (!_dailyList) {
        _dailyList = [NSMutableArray array];
    }
    return _dailyList;
}

- (MKBMLEnergyTableHeaderView *)dailyTableHeader {
    if (!_dailyTableHeader) {
        _dailyTableHeader = [[MKBMLEnergyTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 230.f)];
        _dailyTableHeader.dataModel = self.dailyHeaderModel;
    }
    return _dailyTableHeader;
}

- (MKBMLEnergyTableHeaderViewModel *)dailyHeaderModel {
    if (!_dailyHeaderModel) {
        _dailyHeaderModel = [[MKBMLEnergyTableHeaderViewModel alloc] init];
        _dailyHeaderModel.energyValue = @"0";
        _dailyHeaderModel.timeMsg = @"Hour";
    }
    return _dailyHeaderModel;
}

- (NSString *)fetchCurrentDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateFormat stringFromDate:[NSDate date]];
    return date;
}

@end
