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

static NSString *const kLoginControllerID = @"LoginController";

@interface ChannelsController ()

@end

@implementation ChannelsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
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

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

@end
