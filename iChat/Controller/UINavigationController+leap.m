//
//  UINavigationController+leap.m
//  iChat
//
//  Created by rigo on 24/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "UINavigationController+leap.h"
#import <objc/runtime.h>

static char LOGIN_VIEWCONTROLLER_KEY;

@implementation UINavigationController (leak)

@dynamic loginViewController;

- (void)popToLoginViewControllerAnimated:(BOOL)animated
{
    UIViewController *loginController = objc_getAssociatedObject(self, &LOGIN_VIEWCONTROLLER_KEY);
    
    if(loginController)
    {
        [self popToViewController:loginController animated:animated];
    }
}

- (void)setLoginViewController:(UIViewController *)loginViewController
{
    objc_setAssociatedObject(self, &LOGIN_VIEWCONTROLLER_KEY, loginViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController *)loginViewController
{
    return objc_getAssociatedObject(self, &LOGIN_VIEWCONTROLLER_KEY);
}

@end
