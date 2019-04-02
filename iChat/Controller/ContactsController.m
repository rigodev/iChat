//
//  ContactsController.m
//  iChat
//
//  Created by rigo on 21/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "ContactsController.h"
#import "DataProvider.h"
#import "UserCell.h"
#import "User.h"
#import "ChatController.h"

static NSString *const cellId = @"userCell";
static NSString *const chatControllerId = @"ChatController";

@interface ContactsController ()
{
    NSArray *_contacts;
}

@end

@implementation ContactsController
{
    User *_selectedUser;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startContactsObserving];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopContactsObserving];
    [super viewDidDisappear:animated];
}

- (void)startContactsObserving
{
    [[DataProvider sharedInstance] fetchContactsWithHandler:^(NSArray * _Nonnull users)
     {
         if (users)
         {
             self->_contacts = [users copy];
             [self.tableView reloadData];
         }
     }];
}

- (void)stopContactsObserving
{
    [[DataProvider sharedInstance] removeContactsObservers];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *userContact = _contacts[indexPath.row];
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    [cell setNameText:userContact.name];
//    [cell configureCellWithAvatarImage:nil];
    
    [[DataProvider sharedInstance] downloadProfileImageFromURL:userContact.profileURL complitionHandler:^(NSError * _Nonnull error, NSData * _Nonnull imageData)
     {
         if(error == nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                [cell configureCellWithAvatarImage:[UIImage imageWithData:imageData]];
                            });
         }
     }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (IBAction)backHandler:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatController *chatController = [self.storyboard instantiateViewControllerWithIdentifier:chatControllerId];
    [chatController setReceiverUser:_contacts[indexPath.row]];
    
    [self.navigationController pushViewController:chatController animated:YES];
    
    return nil;
}

@end
