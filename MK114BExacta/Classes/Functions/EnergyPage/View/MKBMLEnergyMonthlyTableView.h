//
//  MKBMLEnergyMonthlyTableView.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLEnergyMonthlyTableView : UIView

/// 更新列表
/// @param energyList 转数数据
/// @param pulseConstant 脉冲常数
- (void)updateEnergyDatas:(NSArray *)energyList pulseConstant:(NSString *)pulseConstant;

/// 用户重置了电能
- (void)resetAllDatas;

@end

NS_ASSUME_NONNULL_END
