//
//  MKBMLTabBarController.m
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKBMLTabBarController.h"

#import "MKMacroDefines.h"
#import "MKBaseNavigationController.h"

#import "MKBMLPowerController.h"
#import "MKBMLEnergyController.h"
#import "MKBMLTimerController.h"
#import "MKBMLSettingsController.h"

#import "MKBMLCentralManager.h"

@interface MKBMLTabBarController ()

@property (nonatomic, strong)UIAlertController *alertController;

@end

@implementation MKBMLTabBarController

- (void)dealloc {
    NSLog(@"MKBMLTabBarController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (![[self.navigationController viewControllers] containsObject:self]){
        [[MKBMLCentralManager shared] disconnect];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubPages];
    [self addNotifications];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leftButtonMethod)
                                                 name:@"mk_bml_popToRootViewControllerNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dfuUpdateComplete)
                                                 name:@"mk_bml_centralDeallocNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(centralManagerStateChanged)
                                                 name:mk_bml_centralManagerStateChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceConnectStateChanged)
                                                 name:mk_bml_peripheralConnectStateChangedNotification
                                               object:nil];
}

#pragma mark - notes
- (void)leftButtonMethod {
    NSString *msg = @"Please confirm again whether to disconnect the device";
    self.alertController = [UIAlertController alertControllerWithTitle:@""
                                                               message:msg
                                                        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [self.alertController addAction:cancelAction];
    @weakify(self);
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self gotoScanPage];
    }];
    [self.alertController addAction:moreAction];
    
    [self presentViewController:self.alertController animated:YES completion:nil];
}

- (void)gotoScanPage {
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(mk_bml_needResetScanDelegate:)]) {
            [self.delegate mk_bml_needResetScanDelegate:NO];
        }
    }];
}

- (void)dfuUpdateComplete {
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(mk_bml_needResetScanDelegate:)]) {
            [self.delegate mk_bml_needResetScanDelegate:YES];
        }
    }];
}

- (void)centralManagerStateChanged{
    if ([MKBMLCentralManager shared].centralStatus != mk_bml_centralManagerStatusEnable) {
        [self showAlertWithMsg:@"The current system of bluetooth is not available!" title:@"Dismiss"];
    }
}

- (void)deviceConnectStateChanged {
    [self showAlertWithMsg:@"The device is disconnected." title:@"Dismiss"];
    return;
}

#pragma mark - private method
- (void)showAlertWithMsg:(NSString *)msg title:(NSString *)title{
    if (self.alertController && (self.presentedViewController == self.alertController)) {
        [self.alertController dismissViewControllerAnimated:NO completion:nil];
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self gotoScanPage];
    }];
    [alertController addAction:moreAction];
    
    //让setting页面推出的alert消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_bml_settingPageNeedDismissAlert" object:nil];
    //让所有MKPickView消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_customUIModule_dismissPickView" object:nil];
    [self performSelector:@selector(presentAlert:) withObject:alertController afterDelay:1.2f];
}

- (void)presentAlert:(UIAlertController *)alert {
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadSubPages {
    MKBMLPowerController *powerPage = [[MKBMLPowerController alloc] init];
    powerPage.tabBarItem.title = @"Power";
    powerPage.tabBarItem.image = LOADICON(@"MK114BExacta", @"MKBMLTabBarController", @"mk_bml_powerTabBarItemUnselected.png");
    powerPage.tabBarItem.selectedImage = LOADICON(@"MK114BExacta", @"MKBMLTabBarController", @"mk_bml_powerTabBarItemSelected.png");
    MKBaseNavigationController *powerNav = [[MKBaseNavigationController alloc] initWithRootViewController:powerPage];

    MKBMLEnergyController *energyPage = [[MKBMLEnergyController alloc] init];
    energyPage.tabBarItem.title = @"Energy";
    energyPage.tabBarItem.image = LOADICON(@"MK114BExacta", @"MKBMLTabBarController", @"mk_bml_energyTabBarItemUnselected.png");
    energyPage.tabBarItem.selectedImage = LOADICON(@"MK114BExacta", @"MKBMLTabBarController", @"mk_bml_energyTabBarItemSelected.png");
    MKBaseNavigationController *energyNav = [[MKBaseNavigationController alloc] initWithRootViewController:energyPage];

    MKBMLTimerController *timerPage = [[MKBMLTimerController alloc] init];
    timerPage.tabBarItem.title = @"Timer";
    timerPage.tabBarItem.image = LOADICON(@"MK114BExacta", @"MKBMLTabBarController", @"mk_bml_timerTabBarItemUnselected.png");
    timerPage.tabBarItem.selectedImage = LOADICON(@"MK114BExacta", @"MKBMLTabBarController", @"mk_bml_timerTabBarItemSelected.png");
    MKBaseNavigationController *timerNav = [[MKBaseNavigationController alloc] initWithRootViewController:timerPage];
    
    MKBMLSettingsController *settingPage = [[MKBMLSettingsController alloc] init];
    settingPage.tabBarItem.title = @"Settings";
    settingPage.tabBarItem.image = LOADICON(@"MK114BExacta", @"MKBMLTabBarController", @"mk_bml_settingTabBarItemUnselected.png");
    settingPage.tabBarItem.selectedImage = LOADICON(@"MK114BExacta", @"MKBMLTabBarController", @"mk_bml_settingTabBarItemSelected.png");
    MKBaseNavigationController *settingNav = [[MKBaseNavigationController alloc] initWithRootViewController:settingPage];
    
    self.viewControllers = @[powerNav,energyNav,timerNav,settingNav];
}

@end
