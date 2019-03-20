//
//  LoginController.m
//  iChat
//
//  Created by rigo on 19/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "LoginController.h"
#import "DataProvider.h"
#import "UIViewController+showAlert.h"

static NSString *const kSegueChannelsID = @"segChannelsID";

@interface LoginController ()

@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet UIButton *regBtn;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupControls];
}

- (void)setupControls
{
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:134 green:140 blue:140 alpha:1]}];
    
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:134 green:140 blue:140 alpha:1]}];
    
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
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(![email isEqualToString:@""] && ![password isEqualToString:@""])
    {
        [[DataProvider sharedInstance] signinUserWithEmail:email password:password handler:^(NSError * _Nonnull error)
         {
             if(error)
             {
                 [self showAlertWithTitle:@"Вход не выполнен!" message:error.userInfo[@"NSLocalizedDescription"]];
                 return;
             }
             
             [self performSegueWithIdentifier:kSegueChannelsID sender:nil];
             return;
         }];
    }
    else
    {
        [self showAlertWithTitle:@"Внимание:" message:@"Вам необходимо заполнить все поля."];
        return;
    }
}

@end
