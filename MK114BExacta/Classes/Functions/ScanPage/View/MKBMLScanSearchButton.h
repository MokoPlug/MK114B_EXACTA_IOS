//
//  MKBMLScanSearchButton.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/30.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLSearchButtonModel : NSObject

/// 显示的标题
@property (nonatomic, copy)NSString *placeholder;

/// 显示的搜索名字
@property (nonatomic, copy)NSString *searchName;

/// 过滤的RSSI值
@property (nonatomic, assign)NSInteger searchRssi;

/// 过滤的最小RSSI值，当searchRssi == minSearchRssi时，不显示searchRssi搜索条件
@property (nonatomic, assign)NSInteger minSearchRssi;

@end

@protocol MKBMLSearchButtonDelegate <NSObject>

/// 搜索按钮点击事件
- (void)bml_scanSearchButtonMethod;

/// 搜索按钮右侧清除按钮点击事件
- (void)bml_scanSearchButtonClearMethod;

@end

@interface MKBMLScanSearchButton : UIControl

@property (nonatomic, strong)MKBMLSearchButtonModel *dataModel;

@property (nonatomic, weak)id <MKBMLSearchButtonDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
