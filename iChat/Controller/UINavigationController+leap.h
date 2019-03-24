//
//  UINavigationController+leap.h
//  iChat
//
//  Created by rigo on 24/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (leak)

@property (nonatomic, weak, nullable) UIViewController *loginViewController;

- (void)popToLoginViewControllerAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
