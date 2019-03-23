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

static NSString *const cellId = @"userCell";

@interface ContactsController ()
{
    NSMutableArray *_userContacts;
}

@end

@implementation ContactsController

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
    [self startUserContactsObserving];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopUserContactsObserving];
    [super viewDidDisappear:animated];
}

- (void)startUserContactsObserving
{
    [[DataProvider sharedInstance] fetchUserContactsWithHandler:^(NSArray * _Nonnull users)
     {
         [self->_userContacts removeAllObjects];
         
         if (users)
         {
             self->_userContacts = [users mutableCopy];
         }
         
         [self.tableView reloadData];
     }];
}

- (void)stopUserContactsObserving
{
    [[DataProvider sharedInstance] removeUserContactsObservers];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userContacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *userContact = _userContacts[indexPath.row];
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    [cell setNameText:userContact.name];
    [cell configureDefaultCellView];
    
    [[DataProvider sharedInstance] getProfileImageFromURL:userContact.profileURL complitionHandler:^(NSError * _Nonnull error, NSData * _Nonnull imageData)
     {
         if(error == nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                [cell setAvatarImage:[UIImage imageWithData:imageData]];
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

@end
