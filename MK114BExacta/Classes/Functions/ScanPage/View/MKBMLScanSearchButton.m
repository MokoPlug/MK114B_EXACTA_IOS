//
//  MKBMLScanSearchButton.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/30.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLScanSearchButton.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

@implementation MKBMLSearchButtonModel
@end

@interface MKBMLScanSearchButton ()

/**
 button的标题
 */
@property (nonatomic, strong)UILabel *titleLabel;

/**
 搜索条件
 */
@property (nonatomic, strong)UILabel *searchLabel;

/**
 清除搜索条件
 */
@property (nonatomic, strong)UIButton *clearButton;

@end

@implementation MKBMLScanSearchButton

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = RGBCOLOR(235, 235, 235);
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:16.f];
        [self.layer setBorderColor:CUTTING_LINE_COLOR.CGColor];
        [self.layer setBorderWidth:0.5f];
        [self addSubview:self.titleLabel];
        [self addSubview:self.searchLabel];
        [self addSubview:self.clearButton];
        [self addTarget:self
                 action:@selector(searchButtonPressed)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.searchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(self.clearButton.mas_left).mas_offset(-10);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(45.f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(self.mas_height);
    }];
}

#pragma mark - Private method

- (void)clearButtonPressed{
    [self.titleLabel setHidden:NO];
    [self.searchLabel setHidden:YES];
    [self.clearButton setHidden:YES];
    if ([self.delegate respondsToSelector:@selector(bml_scanSearchButtonClearMethod)]) {
        [self.delegate bml_scanSearchButtonClearMethod];
    }
}

- (void)searchButtonPressed{
    if ([self.delegate respondsToSelector:@selector(bml_scanSearchButtonMethod)]) {
        [self.delegate bml_scanSearchButtonMethod];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKBMLSearchButtonModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.titleLabel.text = (ValidStr(_dataModel.placeholder) ? _dataModel.placeholder : @"Edit Filter");
    NSMutableArray *conditions = [NSMutableArray array];
    if (ValidStr(_dataModel.searchName)) {
        [conditions addObject:_dataModel.searchName];
    }
    if (_dataModel.searchRssi > _dataModel.minSearchRssi) {
        NSString *rssiValue = [NSString stringWithFormat:@"%lddBm",(long)_dataModel.searchRssi];
        [conditions addObject:rssiValue];
    }
    if (!ValidArray(conditions)) {
        [self.titleLabel setHidden:NO];
        [self.searchLabel setHidden:YES];
        [self.clearButton setHidden:YES];
        return;
    }
    [self.titleLabel setHidden:YES];
    [self.searchLabel setHidden:NO];
    [self.clearButton setHidden:NO];
    NSString *title = @"";
    for (NSString *string in conditions) {
        title = [title stringByAppendingString:[NSString stringWithFormat:@";%@",string]];
    }
    [self.searchLabel setText:[title substringFromIndex:1]];
}

#pragma mark - setter & getter

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBCOLOR(128, 128, 128);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = MKFont(12.f);
        _titleLabel.text = @"Edit Filter";
    }
    return _titleLabel;
}

- (UILabel *)searchLabel{
    if (!_searchLabel) {
        _searchLabel = [[UILabel alloc] init];
        _searchLabel.textColor = DEFAULT_TEXT_COLOR;
        _searchLabel.textAlignment = NSTextAlignmentLeft;
        _searchLabel.font = MKFont(15.f);
    }
    return _searchLabel;
}

- (UIButton *)clearButton{
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearButton setImage:LOADICON(@"MK114BExacta", @"MKBMLScanSearchButton", @"mk_bml_clearButtonIcon.png")
                      forState:UIControlStateNormal];
        [_clearButton addTarget:self
                         action:@selector(clearButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

@end
