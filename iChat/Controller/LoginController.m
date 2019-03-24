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
#import "UINavigationController+leap.h"

static NSString *const kSegueLoginChannelsID = @"Login2Channels";

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
    self.navigationController.loginViewController = self;
    
    [self setupControls];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    self.emailField.text = @"";
    self.passwordField.text = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[DataProvider sharedInstance] currentUserAuthorizedHandler:^(BOOL authorized, NSError * _Nonnull error)
     {
         if(authorized)
         {
             [self performSegueWithIdentifier:kSegueLoginChannelsID sender:nil];
             return;
         }
     }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setupControls
{
    UIColor *placeHolderColor = [UIColor colorWithRed:134.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1];
    
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailField.placeholder attributes:@{NSForegroundColorAttributeName: placeHolderColor}];
    
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: placeHolderColor}];
    
    self.signInView.layer.cornerRadius = 5;
    self.signInView.layer.masksToBounds = true;
    self.regBtn.layer.cornerRadius = 3;
    self.regBtn.layer.masksToBounds = true;
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
             
             [self performSegueWithIdentifier:kSegueLoginChannelsID sender:nil];
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
