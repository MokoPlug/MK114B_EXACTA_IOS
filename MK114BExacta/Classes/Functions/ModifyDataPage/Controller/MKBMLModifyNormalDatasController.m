//
//  MKBMLModifyNormalDatasController.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLModifyNormalDatasController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKTextField.h"

#import "MKBMLInterface+MKBMLConfig.h"

@implementation MKBMLModifyNormalDataModel
@end

@interface MKBMLModifyNormalDatasController ()

@property (nonatomic, strong)MKTextField *textField;

@property (nonatomic, strong)UIButton *confirmButton;

@end

@implementation MKBMLModifyNormalDatasController

- (void)dealloc {
    NSLog(@"MKBMLModifyNormalDatasController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
}

#pragma mark - event method
- (void)confirmButtonPressed {
    if (!ValidStr(self.textField.text)) {
        [self.view showCentralToast:@"Param cannot be empty"];
        return;
    }
    if (self.dataModel.pageType == MKBMLModifyDeviceNamePage) {
        [self configDeviceName];
        return;
    }
    if (self.dataModel.pageType == MKBMLModifyBroadcastFrequencyPage) {
        [self configAdvInterval];
        return;
    }
    if (self.dataModel.pageType == MKBMLModifyOverloadValuePage) {
        [self configOverloadValue];
        return;
    }
    if (self.dataModel.pageType == MKBMLModifyEnergyReportIntervalPage || self.dataModel.pageType == MKBMLModifyPowerChangeNotificationPage) {
        [self configEnergyValue];
        return;
    }
    if (self.dataModel.pageType == MKBMLModifyPowerReportIntervalPage) {
        [self configPowerValue];
        return;
    }
}

#pragma mark - interface
- (void)configDeviceName {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_configDeviceName:self.textField.text sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configAdvInterval {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_configAdvInterval:[self.textField.text integerValue] sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configOverloadValue {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_configOverloadProtectionValue:[self.textField.text integerValue] sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configEnergyValue {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    NSInteger interval = (self.dataModel.pageType == MKBMLModifyEnergyReportIntervalPage ? [self.textField.text integerValue] : [self.dataModel.powerValue integerValue]);
    NSInteger energy = (self.dataModel.pageType == MKBMLModifyPowerChangeNotificationPage ? [self.textField.text integerValue] : [self.dataModel.powerValue integerValue]);
    [MKBMLInterface bml_configEnergyStorageParameters:interval energyValue:energy sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configPowerValue {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_configVCReportInterval:[self.textField.text integerValue] sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = RGBCOLOR(38,129,255);
    self.view.backgroundColor = RGBCOLOR(242, 242, 242);
    self.defaultTitle = [self fetchTitle];
    self.textField = [self loadTextField];
    self.textField.text = self.dataModel.textFieldValue;
    
    UIView *textView = [self textView];
    [self.view addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(-30.f);
        make.top.mas_equalTo(defaultTopInset + 40.f);
        make.height.mas_equalTo(40.f);
    }];
    [textView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.view addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(-30.f);
        make.top.mas_equalTo(textView.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(40.f);
    }];
}

#pragma mark - getter

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.backgroundColor = RGBCOLOR(38,129,255);
        _confirmButton.titleLabel.font = MKFont(18.f);
        [_confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        
        [_confirmButton.layer setMasksToBounds:YES];
        [_confirmButton.layer setCornerRadius:20.f];
        [_confirmButton addTarget:self
                           action:@selector(confirmButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIView *)textView {
    UIView *textView = [[UIView alloc] init];
    textView.backgroundColor = RGBCOLOR(245, 245, 245);
    
    textView.layer.masksToBounds = YES;
    textView.layer.borderColor = RGBCOLOR(217, 217, 217).CGColor;
    textView.layer.borderWidth = 0.5f;
    textView.layer.cornerRadius = 20.f;
    return textView;
}

- (MKTextField *)loadTextField {
    mk_textFieldType type = mk_normal;
    if (self.dataModel.pageType != MKBMLModifyDeviceNamePage) {
        type = mk_realNumberOnly;
    }
    MKTextField *textField = [[MKTextField alloc] initWithTextFieldType:type];
    textField.backgroundColor = RGBCOLOR(245, 245, 245);
    textField.textColor = RGBCOLOR(128, 128, 128);
    textField.font = MKFont(15.f);
    textField.textAlignment = NSTextAlignmentLeft;
    textField.borderStyle = UITextBorderStyleNone;
    return textField;
}

- (NSString *)fetchTitle {
    switch (self.dataModel.pageType) {
        case MKBMLModifyDeviceNamePage:
            return self.dataModel.textFieldValue;
        case MKBMLModifyBroadcastFrequencyPage:
            return @"Broadcast frequency";
        case MKBMLModifyOverloadValuePage:
            return @"Overload value";
        case MKBMLModifyEnergyReportIntervalPage:
            return @"Energy reporting interval";
        case MKBMLModifyPowerChangeNotificationPage:
            return @"Power change notification";
        case MKBMLModifyPowerReportIntervalPage:
            return @"Power reporting Interval";
    }
}

@end

