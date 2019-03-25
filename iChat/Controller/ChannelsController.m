//
//  ChannelsController.m
//  iChat
//
//  Created by rigo on 19/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "ChannelsController.h"
#import "DataProvider.h"
#import "User.h"
#import "Message.h"

static NSString *const kLoginControllerID = @"LoginController";
static NSString *const cellId = @"defaultCellId";

@interface ChannelsController ()
{
    NSArray *_messages;
    NSString *_currentUserId;
}

@end

@implementation ChannelsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentUserId = [[DataProvider sharedInstance] getCurrentUserId];
    [self getUserName];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)getUserName
{
    [[DataProvider sharedInstance] fetchCurrentUserWithHandler:^(User * _Nonnull user)
     {
         if(user)
         {
             self.navigationItem.title = user.name;
         }
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    [self startChatObserving];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopChatObserving];
    [super viewDidDisappear:animated];
}

- (void)startChatObserving
{
    NSString *currentUserId = [[DataProvider sharedInstance] getCurrentUserId];
    [[DataProvider sharedInstance] observeChatsForUserId:currentUserId withComplitionHandler:^(NSArray * _Nonnull messages)
    {
        if (messages)
        {
            self->_messages = [messages copy];
            [self.tableView reloadData];
        }
    }];
}

- (void)stopChatObserving
{
    [[DataProvider sharedInstance] removeChatsObservingForUserId:_currentUserId];
}

- (IBAction)logoutTapHandle:(id)sender
{
    [[DataProvider sharedInstance] signOutHandler:^(NSError * _Nonnull error)
     {
         if(error)
         {
             return;
         }
         
         [self.navigationController popToRootViewControllerAnimated:YES];
     }];
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
    cell.detailTextLabel.text = message.messageText;
    cell.textLabel.text = message.senderUserId;

    return cell;
}

@end
