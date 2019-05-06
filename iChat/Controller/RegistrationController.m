//
//  RegistrationController.m
//  iChat
//
//  Created by rigo on 20/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import "RegistrationController.h"
#import "UIViewController+showAlert.h"
#import "DataProvider.h"

static NSString *const kSegueRegistrationChannelsID = @"Registration2Channels";

@interface RegistrationController () <UITextFieldDelegate>

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
    self.emailField.delegate = self;
    self.emailField.layer.cornerRadius = 15;
    self.emailField.layer.masksToBounds = true;
    
    self.passwordField.delegate = self;
    self.passwordField.layer.cornerRadius = 15;
    self.passwordField.layer.masksToBounds = true;
    
    self.nameField.delegate = self;
    self.nameField.layer.cornerRadius = 15;
    self.nameField.layer.masksToBounds = true;
    
    self.createBtn.layer.cornerRadius = 5;
    self.createBtn.layer.masksToBounds = true;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)cancelHandle:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)signUpHandle:(id)sender
{
    NSString *name = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    DataProvider *dataProvider = [DataProvider sharedInstance];
    
    if(![name isEqualToString:@""] && ![email isEqualToString:@""] && ![password isEqualToString:@""])
    {
        
        [dataProvider signupUserWithName:name email:email password:password handler:^(NSError * _Nonnull error)
         {
             if(error)
             {
                 [self showAlertWithTitle:@"Регистрация не выполнена!" message:error.userInfo[@"NSLocalizedDescription"]];
                 return;
             }
             
             [self performSegueWithIdentifier:kSegueRegistrationChannelsID sender:nil];
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
