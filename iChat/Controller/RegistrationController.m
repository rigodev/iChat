//
//  RegistrationController.m
//  iChat
//
//  Created by rigo on 20/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "RegistrationController.h"
#import "UIViewController+showAlert.h"
#import "DataProvider.h"

static NSString *const kSegueChannelsID = @"segChannelsID";

@interface RegistrationController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;

@end

@implementation RegistrationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupControls];
}

- (void)setupControls
{
    UIColor *borderColor = [UIColor colorWithRed:59.0/255.0 green:75.0/255.0 blue:104.0/255.0 alpha:1.0];
    UIColor *placeHolderTextColor = [UIColor lightGrayColor];
    
    self.emailField.layer.cornerRadius = 15;
    self.emailField.layer.masksToBounds = true;
    self.emailField.layer.borderWidth = 3;
    self.emailField.layer.borderColor = [borderColor CGColor];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailField.placeholder attributes:@{NSForegroundColorAttributeName: placeHolderTextColor}];
    
    self.passwordField.layer.cornerRadius = 15;
    self.passwordField.layer.masksToBounds = true;
    self.passwordField.layer.borderWidth = 3;
    self.passwordField.layer.borderColor = [borderColor CGColor];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: placeHolderTextColor}];
    
    self.nameField.layer.cornerRadius = 15;
    self.nameField.layer.masksToBounds = true;
    self.nameField.layer.borderWidth = 3;
    self.nameField.layer.borderColor = [borderColor CGColor];
    self.nameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.nameField.placeholder attributes:@{NSForegroundColorAttributeName: placeHolderTextColor}];
    
    self.createBtn.layer.cornerRadius = 5;
    self.createBtn.layer.masksToBounds = true;
}

- (IBAction)cancelHandle:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signUpHandle:(id)sender
{
    NSString *name = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(![name isEqualToString:@""] && ![email isEqualToString:@""] && ![password isEqualToString:@""])
    {
        [[DataProvider sharedInstance] signupUserWithName:name email:email password:password handler:^(NSError * _Nonnull error)
         {
             if(error)
             {
                 [self showAlertWithTitle:@"Регистрация не выполнена!" message:error.userInfo[@"NSLocalizedDescription"]];
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