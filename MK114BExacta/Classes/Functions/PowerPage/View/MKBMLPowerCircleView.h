//
//  MKBMLPowerCircleView.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLPowerCircleView : UIView

///最大3600，超过3600表示进度为1
/// @param powerValue powerValue
- (void)updatePowerValues:(float)powerValue;

@end

NS_ASSUME_NONNULL_END
