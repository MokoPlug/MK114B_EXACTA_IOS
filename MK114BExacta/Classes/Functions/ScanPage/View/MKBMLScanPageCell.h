//
//  MKBMLScanPageCell.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/30.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

#import "MKBMLDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLScanPageCell : MKBaseCell

@property (nonatomic, strong)MKBMLDeviceModel *dataModel;

+ (MKBMLScanPageCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
