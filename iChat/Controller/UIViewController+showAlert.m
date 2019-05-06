//
//  UIViewController+showAlert.m
//  iChat
//
//  Created by rigo on 20/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import "UIViewController+showAlert.h"

@implementation UIViewController (showAlert)

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"ОК" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
