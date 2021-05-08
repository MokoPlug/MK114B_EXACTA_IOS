//
//  MKBMLEnergyTableHeaderView.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLEnergyTableHeaderViewModel : NSObject

@property (nonatomic, copy)NSString *energyValue;

@property (nonatomic, copy)NSString *dateMsg;

@property (nonatomic, copy)NSString *timeMsg;

@end

@interface MKBMLEnergyTableHeaderView : UIView

@property (nonatomic, strong)MKBMLEnergyTableHeaderViewModel *dataModel;

@end

NS_ASSUME_NONNULL_END
