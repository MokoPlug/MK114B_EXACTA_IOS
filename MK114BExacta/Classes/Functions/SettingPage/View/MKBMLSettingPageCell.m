//
//  MKBMLSettingPageCell.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLSettingPageCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

@implementation MKBMLSettingPageCellModel
@end

@interface MKBMLSettingPageCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *valueLabel;

@property (nonatomic, strong)UIImageView *rightIcon;

@end

@implementation MKBMLSettingPageCell

+ (MKBMLSettingPageCell *)initCellWithTableView:(UITableView *)tableView {
    MKBMLSettingPageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKBMLSettingPageCellIdenty"];
    if (!cell) {
        cell = [[MKBMLSettingPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKBMLSettingPageCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.valueLabel];
        [self.contentView addSubview:self.rightIcon];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(40.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(6.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(10.f);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(self.rightIcon.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(12.f).lineHeight);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKBMLSettingPageCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.leftMsg);
    self.valueLabel.text = SafeStr(_dataModel.rightMsg);
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
    }
    return _msgLabel;
}

- (UIImageView *)rightIcon {
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] init];
        _rightIcon.image = LOADICON(@"MK114BExacta", @"MKBMLSettingPageCell", @"mk_bml_goto_next_button.png");
    }
    return _rightIcon;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textColor = RGBCOLOR(128, 128, 128);
        _valueLabel.textAlignment = NSTextAlignmentRight;
        _valueLabel.font = MKFont(12.f);
    }
    return _valueLabel;
}

@end
