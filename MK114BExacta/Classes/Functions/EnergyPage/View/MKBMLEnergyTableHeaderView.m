//
//  MKBMLEnergyTableHeaderView.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLEnergyTableHeaderView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

@implementation MKBMLEnergyTableHeaderViewModel
@end

@interface MKBMLEnergyTableHeaderView ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *totalMsgLabel;

@property (nonatomic, strong)UILabel *energyValueLabel;

@property (nonatomic, strong)UILabel *unitLabel;

@property (nonatomic, strong)UILabel *dateLabel;

@property (nonatomic, strong)UILabel *timeLabel;

@property (nonatomic, strong)UILabel *energyUnitLabel;

@property (nonatomic, strong)UIView *lineView;

@end

@implementation MKBMLEnergyTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.msgLabel];
        [self addSubview:self.totalMsgLabel];
        [self addSubview:self.energyValueLabel];
        [self addSubview:self.unitLabel];
        [self addSubview:self.dateLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:self.energyUnitLabel];
        [self addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24.f);
        make.right.mas_equalTo(-24.f);
        make.top.mas_equalTo(10.f);
        make.height.mas_equalTo(MKFont(18.f).lineHeight);
    }];
    [self.energyValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(150.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(40.f);
        make.height.mas_equalTo(MKFont(30.f).lineHeight);
    }];
    [self.totalMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.energyValueLabel.mas_left).mas_offset(-10.f);
        make.width.mas_equalTo(40.f);
        make.bottom.mas_equalTo(self.energyValueLabel.mas_bottom);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.energyValueLabel.mas_right).mas_offset(10.f);
        make.width.mas_equalTo(40.f);
        make.bottom.mas_equalTo(self.energyValueLabel.mas_bottom);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24.f);
        make.right.mas_equalTo(-24.f);
        make.top.mas_equalTo(self.unitLabel.mas_bottom).mas_offset(60.f);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.mas_centerX).mas_offset(-5.f);
        make.top.mas_equalTo(self.dateLabel.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.energyUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.left.mas_equalTo(self.mas_centerX).mas_offset(5.f);
        make.bottom.mas_equalTo(self.timeLabel.mas_bottom);
        make.height.mas_equalTo(MKFont(16.f).lineHeight);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKBMLEnergyTableHeaderViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.energyValueLabel.text = (_dataModel.energyValue ? _dataModel.energyValue : @"0");
    self.dateLabel.text = SafeStr(_dataModel.dateMsg);
    self.timeLabel.text = SafeStr(_dataModel.timeMsg);
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = MKFont(18.f);
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.text = @"Energy";
    }
    return _msgLabel;
}

- (UILabel *)totalMsgLabel {
    if (!_totalMsgLabel) {
        _totalMsgLabel = [[UILabel alloc] init];
        _totalMsgLabel.textColor = RGBCOLOR(128, 128, 128);
        _totalMsgLabel.textAlignment = NSTextAlignmentRight;
        _totalMsgLabel.font = MKFont(14.f);
        _totalMsgLabel.text = @"Total";
    }
    return _totalMsgLabel;
}

- (UILabel *)energyValueLabel {
    if (!_energyValueLabel) {
        _energyValueLabel = [[UILabel alloc] init];
        _energyValueLabel.textColor = RGBCOLOR(38,129,255);
        _energyValueLabel.font = MKFont(30.f);
        _energyValueLabel.textAlignment = NSTextAlignmentCenter;
        _energyValueLabel.text = @"0.0";
    }
    return _energyValueLabel;
}

- (UILabel *)unitLabel {
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.textColor = RGBCOLOR(128, 128, 128);
        _unitLabel.textAlignment = NSTextAlignmentLeft;
        _unitLabel.font = MKFont(14.f);
        _unitLabel.text = @"KWh";
    }
    return _unitLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = RGBCOLOR(128, 128, 128);
        _dateLabel.textAlignment = NSTextAlignmentRight;
        _dateLabel.font = MKFont(13.f);
    }
    return _dateLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = DEFAULT_TEXT_COLOR;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.font = MKFont(15.f);
    }
    return _timeLabel;
}

- (UILabel *)energyUnitLabel {
    if (!_energyUnitLabel) {
        _energyUnitLabel = [[UILabel alloc] init];
        _energyUnitLabel.textColor = DEFAULT_TEXT_COLOR;
        _energyUnitLabel.textAlignment = NSTextAlignmentRight;
        _energyUnitLabel.font = MKFont(16.f);
        _energyUnitLabel.text = @"KWh·EC";
    }
    return _energyUnitLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = CUTTING_LINE_COLOR;
    }
    return _lineView;
}

@end
