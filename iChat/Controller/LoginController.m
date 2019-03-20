//
//  LoginController.m
//  iChat
//
//  Created by rigo on 19/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "LoginController.h"
#import "DataProvider.h"

static NSString *const kSegueChannelsID = @"segChannelsID";

@interface LoginController ()

@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet UIButton *regBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.signInView.layer.cornerRadius = 5;
    self.signInView.layer.masksToBounds = true;
    self.regBtn.layer.cornerRadius = 3;
    self.regBtn.layer.masksToBounds = true;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)loginTapHandle:(id)sender
{
    NSString *name = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(![name isEqualToString:@""] && ![email isEqualToString:@""] && ![password isEqualToString:@""])
    {
        [[DataProvider sharedInstance] registrUserName:name
                                                 email:email
                                              password:password
                                               handler:^(NSError * _Nonnull error)
         {
             if(error)
             {
                 [self showAlertWithTitle:@"Регистрация неуспешна" message:error.userInfo[@"NSLocalizedDescription"]];
                 return;
             }
             
             [self performSegueWithIdentifier:kSegueChannelsID sender:nil];
         }];        
    }
    else
    {
        [self showAlertWithTitle:@"Внимание:" message:@"Вам необходимо заполнить все поля."];
        return;
    }
}

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
