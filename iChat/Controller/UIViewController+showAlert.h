//
//  UIViewController+showAlert.h
//  iChat
//
//  Created by rigo on 20/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (showAlert)

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
