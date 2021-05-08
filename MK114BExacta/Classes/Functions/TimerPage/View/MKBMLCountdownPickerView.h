//
//  MKBMLCountdownPickerView.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/5.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLCountdownPickerView : UIView

/// 加载pickView
/// @param msg pickView显示的title
/// @param completeBlock 用户点击了confirm按钮的回调事件
- (void)showPickViewWithTitleMsg:(NSString *)msg
                   completeBlock:(void (^)(NSInteger seconds))completeBlock;

@end

NS_ASSUME_NONNULL_END
