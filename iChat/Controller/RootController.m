//
//  RootController.m
//  iChat
//
//  Created by rigo on 20/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "RootController.h"
#import "DataProvider.h"

static NSString *const kSegueLoginID = @"segLoginID";
static NSString *const kSegueChannelsID = @"segChannelsID";

@interface RootController ()

@end

@implementation RootController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[DataProvider sharedInstance] currentUserAuthorizedHandler:^(BOOL authorized, NSError * _Nonnull error)
     {
         if(authorized)
         {
             [self performSegueWithIdentifier:kSegueChannelsID sender:nil];
         }
         else
         {
             [self performSegueWithIdentifier:kSegueLoginID sender:nil];
         }
     }];
}

@end
