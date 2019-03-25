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

static NSString *const cellId = @"cellId";

@interface ChatController () <UITextFieldDelegate, UITableViewDataSource>
{
    User *_receiverUser;
    NSString *_currentUserId, *_contactUserId;
    NSArray *_messages;
}

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet UITextField *messageField;

@end

@implementation ChatController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.messageField.delegate = self;
    self.chatTableView.dataSource = self;
    _currentUserId = [[DataProvider sharedInstance] getCurrentUserId];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startChatObserving];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopChatObserving];
    [super viewDidDisappear:animated];
}

- (void)startChatObserving
{
    [[DataProvider sharedInstance] observeChatForUserId:_currentUserId withContactUserId:_contactUserId WithComplitionHandler:^(NSArray * _Nonnull messages)
    {
        if(messages)
        {
            self-> _messages = messages;
            [self.chatTableView reloadData];
        }
    }];
}

- (void)stopChatObserving
{
    [[DataProvider sharedInstance] removeChatObservingForUserId:_currentUserId withContactUserId:_contactUserId];
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
    
    if(![chatMessage isEqualToString:@""] && _currentUserId && _contactUserId)
    {
        Message *message = [Message new];
        message.messageText = chatMessage;
        message.senderUserId = _currentUserId;
        message.receiverUserId = _contactUserId;
        
        [[DataProvider sharedInstance] sendMessage:message withComplitionHandler:^(NSError * _Nonnull error)
        {
            if(!error)
            {
                self.messageField.text = @"";
            }
        }];
    }
}

- (void)setReceiverUser:(User *)receiverUser;
{
    _receiverUser = receiverUser;
    _contactUserId = receiverUser.uid;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
   
    Message *message = _messages[indexPath.row];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"HH:mm:ss";
    
    cell.textLabel.text = message.messageText;
    cell.detailTextLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970: message.timestamp.doubleValue/1000.0]];

    return cell;
}

@end
