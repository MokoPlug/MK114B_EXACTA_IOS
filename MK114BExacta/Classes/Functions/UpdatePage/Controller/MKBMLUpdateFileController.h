//
//  MKBMLUpdateFileController.h
//  MK114BExacta_Example
//
//  Created by aa on 2021/5/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKBMLUpdateFileControllerDelegate <NSObject>

- (void)mk_bml_selectedFileName:(NSString *)fileName;

@end

@interface MKBMLUpdateFileController : MKBaseViewController

@property (nonatomic, weak)id <MKBMLUpdateFileControllerDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
