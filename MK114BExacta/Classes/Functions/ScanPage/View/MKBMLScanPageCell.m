//
//  MKBMLScanPageCell.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/30.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLScanPageCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

@interface MKBMLScanPageCell ()

@property (nonatomic, strong)UIView *backColorView;

@property (nonatomic, strong)UILabel *deviceNameLabel;

@property (nonatomic, strong)UILabel *rssiLabel;

@property (nonatomic, strong)UILabel *stateValueLabel;

@end

@implementation MKBMLScanPageCell

+ (MKBMLScanPageCell *)initCellWithTableView:(UITableView *)tableView {
    MKBMLScanPageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKBMLScanPageCellIdenty"];
    if (!cell) {
        cell = [[MKBMLScanPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKBMLScanPageCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = RGBCOLOR(245, 245, 245);
        [self.contentView addSubview:self.backColorView];
        [self.backColorView addSubview:self.deviceNameLabel];
        [self.backColorView addSubview:self.rssiLabel];
        [self.backColorView addSubview:self.stateValueLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.backColorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10.f);
        make.top.mas_equalTo(5.f);
        make.bottom.mas_equalTo(-5.f);
    }];
    [self.rssiLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(80.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.deviceNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.rssiLabel.mas_left).mas_offset(-10.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.stateValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.rssiLabel.mas_left).mas_offset(-10.f);
        make.bottom.mas_equalTo(-10.f);
        make.height.mas_equalTo(MKFont(12.f).lineHeight);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKBMLDeviceModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(_dataModel.deviceName)) {
        self.deviceNameLabel.text = _dataModel.deviceName;
    }else {
        self.deviceNameLabel.text = @"N/A";
    }
    self.rssiLabel.text = [NSString stringWithFormat:@"%lddBm",(long)_dataModel.rssi];
    if (_dataModel.overloadState) {
        //过载
        self.stateValueLabel.text = @"OVERLOAD";
        return;
    }
    //不过载
    if (!_dataModel.switchStatus) {
        //开关关闭
        self.stateValueLabel.text = @"OFF";
        return;
    }
    //开关打开
    NSString *electronV = [NSString stringWithFormat:@"%.1f",_dataModel.electronV];
    NSString *electronA = [NSString stringWithFormat:@"%.3f",(_dataModel.electronA * 0.001)];
    NSString *electronP = [NSString stringWithFormat:@"%.1f",_dataModel.electronP];
    NSString *valueInfo = [NSString stringWithFormat:@"ON,%@W,%@V,%@A",electronP,electronV,electronA];
    self.stateValueLabel.text = valueInfo;
}

#pragma mark - getter
- (UIView *)backColorView {
    if (!_backColorView) {
        _backColorView = [[UIView alloc] init];
        _backColorView.backgroundColor = COLOR_WHITE_MACROS;
        
        _backColorView.layer.masksToBounds = YES;
        _backColorView.layer.cornerRadius = 4.f;
    }
    return _backColorView;
}

- (UILabel *)deviceNameLabel {
    if (!_deviceNameLabel) {
        _deviceNameLabel = [[UILabel alloc] init];
        _deviceNameLabel.textColor = RGBCOLOR(38,129,255);
        _deviceNameLabel.font = MKFont(14.f);
        _deviceNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _deviceNameLabel;
}

- (UILabel *)rssiLabel {
    if (!_rssiLabel) {
        _rssiLabel = [[UILabel alloc] init];
        _rssiLabel.textColor = RGBCOLOR(128, 128, 128);
        _rssiLabel.font = MKFont(14.f);
        _rssiLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _rssiLabel;
}

- (UILabel *)stateValueLabel {
    if (!_stateValueLabel) {
        _stateValueLabel = [[UILabel alloc] init];
        _stateValueLabel.textColor = RGBCOLOR(191, 191, 191);
        _stateValueLabel.font = MKFont(12.f);
        _stateValueLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _stateValueLabel;
}

@end
