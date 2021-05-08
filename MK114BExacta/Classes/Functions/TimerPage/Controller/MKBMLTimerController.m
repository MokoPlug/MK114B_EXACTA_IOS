//
//  MKBMLTimerController.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLTimerController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"

#import "MKBMLTimerDataModel.h"
#import "MKBMLCountdownPickerView.h"
#import "MKBMLTimerCircleView.h"

#import "MKBMLCentralManager.h"
#import "MKBMLInterface+MKBMLConfig.h"

#import "MKBMLDeviceInfoController.h"

static CGFloat const circleView_offset_X = 40.f;
static CGFloat const buttonWidth = 120.f;
static CGFloat const buttonHeight = 32.f;

@interface MKBMLTimerController ()

@property (nonatomic, strong)MKBMLTimerCircleView *circleView;

@property (nonatomic, strong)UIButton *timerButton;

@property (nonatomic, strong)UILabel *stateLabel;

@property (nonatomic, strong)UIImageView *haloRingView;

@property (nonatomic, strong)UILabel *timerLabel;

@property (nonatomic, strong)MKBMLTimerDataModel *dataModel;

@end

@implementation MKBMLTimerController

- (void)dealloc {
    NSLog(@"MKBMLTimerController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startReadDatas];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCountdownTimerData:)
                                                 name:mk_bml_receiveCountdownNotification
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

#pragma mark - Notification
- (void)receiveCountdownTimerData:(NSNotification *)note {
    /*
     note: @{
@"isOn":@(isOn),//此处的isOn跟读取回来的倒计时状态不一样，这个isOn是倒计时结束之后开关的状态，读取回来的倒计时里面的isOn是指当前倒计时有没有打开
@"configValue":configValue,
@"remainingTime":remainingTime,
     };
     */
    NSString *state = ([note.userInfo[@"isOn"] boolValue] ? @"ON" : @"OFF");
    self.stateLabel.text = [state stringByAppendingString:@" after countdown"];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:@(YES) forKey:@"isOn"];
    [dataDic setObject:note.userInfo[@"configValue"] forKey:@"configValue"];
    [dataDic setObject:note.userInfo[@"remainingTime"] forKey:@"remainingTime"];
    [self reloadCircles:dataDic];
}

#pragma mark - event method
- (void)timerButtonPressed {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_readSwitchStatusWithSucBlock:^(id  _Nonnull returnData) {
        [[MKHudManager share] hide];
        [self showPickViewWithSwitchStatus:[returnData[@"result"][@"isOn"] boolValue]];
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
        self.defaultTitle = self.dataModel.deviceName;
        [self reloadCircles:self.dataModel.countdown];
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configCountdownValue:(long long)seconds {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKBMLInterface bml_configCountdownValue:seconds sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (void)reloadCircles:(NSDictionary *)returnData {
    BOOL isOn = [returnData[@"isOn"] boolValue];
    if (!isOn) {
        //倒计时未打开
        self.stateLabel.hidden = YES;
        self.timerLabel.text = @"Timer";
        [self.circleView updateProgress:0];
        return;
    }
    //倒计时打开
    self.stateLabel.hidden = NO;
    self.timerLabel.text = [self getTimeWithSec:returnData[@"remainingTime"]];
    if ([returnData[@"remainingTime"] floatValue] == 0) {
        //倒计时结束
        self.stateLabel.hidden = YES;
    }
    float progress = (1 - [returnData[@"remainingTime"] floatValue] / [returnData[@"configValue"] floatValue]);
    [self.circleView updateProgress:progress];
}

- (void)showPickViewWithSwitchStatus:(BOOL)isOn {
    MKBMLCountdownPickerView *pickView = [[MKBMLCountdownPickerView alloc] init];
    NSString *titleMsg = (isOn ? @"Countdown timer(off)" : @"Countdown timer(on)");
    [pickView showPickViewWithTitleMsg:titleMsg completeBlock:^(NSInteger seconds) {
        [self configCountdownValue:seconds];
    }];
}

- (NSString *)getTimeWithSec:(NSString *)second{
    NSInteger minutes = floor([second integerValue] / 60);
    NSInteger sec = trunc([second integerValue] - minutes * 60);
    NSInteger hours1 = floor([second integerValue] / (60 * 60));
    minutes = minutes - hours1 * 60;
    
    NSString *hourString = [NSString stringWithFormat:@"%ld",(long)hours1];
    if (hourString.length == 1) {
        hourString = [@"0" stringByAppendingString:hourString];
    }
    NSString *minuteString = [NSString stringWithFormat:@"%ld",(long)minutes];
    if (minuteString.length == 1) {
        minuteString = [@"0" stringByAppendingString:minuteString];
    }
    NSString *secString = [NSString stringWithFormat:@"%ld",(long)sec];
    if (secString.length == 1) {
        secString = [@"0" stringByAppendingString:secString];
    }
    
    return [NSString stringWithFormat:@"%@:%@:%@",hourString,minuteString,secString];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = RGBCOLOR(38,129,255);
    self.view.backgroundColor = RGBCOLOR(242, 242, 242);
    [self.rightButton setImage:LOADICON(@"MK114BExacta", @"MKBMLPowerController", @"mk_bml_detailIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.circleView];
    [self.view addSubview:self.haloRingView];
    [self.haloRingView addSubview:self.timerLabel];
    
    [self.haloRingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.circleView.mas_left).mas_offset(25.f);
        make.right.mas_equalTo(self.circleView.mas_right).mas_offset(-25.f);
        make.top.mas_equalTo(self.circleView.mas_top).mas_offset(25.f);
        make.bottom.mas_equalTo(self.circleView.mas_bottom).mas_offset(-25.f);
    }];
    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.centerY.mas_equalTo(self.haloRingView.mas_centerY);
        make.height.mas_equalTo(MKFont(30.f).lineHeight);
    }];
    
    [self.view addSubview:self.timerButton];
    [self.timerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.circleView.mas_bottom).mas_offset(20.f);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
    }];
    [self.view addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.timerButton.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
}

#pragma mark - getter
- (MKBMLTimerCircleView *)circleView {
    if (!_circleView) {
        _circleView = [[MKBMLTimerCircleView alloc] initWithFrame:CGRectMake(circleView_offset_X,
                                                                             defaultTopInset + 60.f,
                                                                             kViewWidth - 2 * circleView_offset_X,
                                                                             kViewWidth - 2 * circleView_offset_X)];
    }
    return _circleView;
}

- (UIImageView *)haloRingView {
    if (!_haloRingView) {
        _haloRingView = [[UIImageView alloc] init];
        _haloRingView.image = LOADIMAGE(@"haloRing", @"png");
        _haloRingView.userInteractionEnabled = YES;
    }
    return _haloRingView;
}

- (UILabel *)timerLabel {
    if (!_timerLabel) {
        _timerLabel = [[UILabel alloc] init];
        _timerLabel.textColor = RGBCOLOR(38,129,255);
        _timerLabel.textAlignment = NSTextAlignmentCenter;
        _timerLabel.font = MKFont(30.f);
        _timerLabel.text = @"Timer";
    }
    return _timerLabel;
}

- (UIButton *)timerButton {
    if (!_timerButton) {
        _timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _timerButton.backgroundColor = RGBCOLOR(38,129,255);
        _timerButton.titleLabel.font = MKFont(15.f);
        [_timerButton setTitle:@"Set timer" forState:UIControlStateNormal];
        [_timerButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        _timerButton.layer.masksToBounds = YES;
        _timerButton.layer.cornerRadius = 14.f;
        [_timerButton addTapAction:self selector:@selector(timerButtonPressed)];
    }
    return _timerButton;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textColor = RGBCOLOR(128, 128, 128);
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.font = MKFont(14.f);
        _stateLabel.text = @"OFF after countdown";
    }
    return _stateLabel;
}

- (MKBMLTimerDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKBMLTimerDataModel alloc] init];
    }
    return _dataModel;
}

@end
