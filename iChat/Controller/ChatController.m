//
//  ChatController.m
//  iChat
//
//  Created by rigo on 23/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "ChatController.h"
#import "DataProvider.h"
#import "User.h"
#import "Message.h"
#import "UINavigationController+leap.h"

@interface ChatController () <UITextFieldDelegate>
{
    User *_receiverUser;
    NSString *_senderUserId;
}

@property (weak, nonatomic) IBOutlet UITextField *messageField;

@end

@implementation ChatController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.messageField.delegate = self;
    _senderUserId = [[DataProvider sharedInstance] getCurrentUserId];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)handleBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self handleSend:nil];
    return YES;
}

- (IBAction)handleSend:(id)sender
{
    NSString *chatMessage = [self.messageField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(![chatMessage isEqualToString:@""] && _senderUserId && _receiverUser.uid)
    {
        Message *message = [Message new];
        message.messageText = chatMessage;
        message.senderUserId = _senderUserId;
        message.receiverUserId = _receiverUser.uid;
        
        [[DataProvider sharedInstance] sendMessage:message withComplitionHandler:^(NSError * _Nonnull error) {}];
    }
}

- (void)setReceiverUser:(User *)receiverUser;
{
    _receiverUser = receiverUser;
}

@end
