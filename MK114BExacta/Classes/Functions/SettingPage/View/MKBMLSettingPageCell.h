//
//  MKBMLSettingPageCell.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLSettingPageCellModel : NSObject

@property (nonatomic, copy)NSString *leftMsg;

@property (nonatomic, copy)NSString *rightMsg;

@property (nonatomic, copy)NSString *methodName;

@end

@interface MKBMLSettingPageCell : MKBaseCell

@property (nonatomic, strong)MKBMLSettingPageCellModel *dataModel;

+ (MKBMLSettingPageCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
