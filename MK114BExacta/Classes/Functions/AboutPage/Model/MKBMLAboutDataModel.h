//
//  MKBMLAboutDataModel.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/4/30.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBMLAboutDataModel : NSObject

@property (nonatomic, copy)NSString *typeMessage;

@property (nonatomic, copy)NSString *value;

@property (nonatomic, copy)NSString *iconName;

@property (nonatomic, assign)BOOL canAdit;

@end

NS_ASSUME_NONNULL_END
