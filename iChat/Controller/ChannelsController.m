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

@interface ChannelsController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSArray *_messages;
    NSString *_currentUserId;
    User *_currentUser;
}

@end

@implementation ChannelsController
{
    UIImageView *profileImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentUserId = [[DataProvider sharedInstance] getCurrentUserId];
    [self getCurrentUser];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)getCurrentUser
{
    [[DataProvider sharedInstance] fetchCurrentUserWithHandler:^(User * _Nonnull user)
     {
         if(user)
         {
             self->_currentUser = user;
             [self setupTitleViewForNavigationBar];
         }
     }];
}

- (void)setupTitleViewForNavigationBar
{
    UIView *titleView = [UIView new];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfileTap)];
    [titleView addGestureRecognizer:tapGesture];
    
    profileImageView = [UIImageView new];
    [titleView addSubview:profileImageView];
    profileImageView.translatesAutoresizingMaskIntoConstraints = false;
    [profileImageView.leftAnchor constraintEqualToAnchor:titleView.leftAnchor].active = true;
    [profileImageView.topAnchor constraintEqualToAnchor:titleView.topAnchor];
    [profileImageView.heightAnchor constraintEqualToAnchor:titleView.heightAnchor constant:-4.0].active = true;
    [profileImageView.widthAnchor constraintEqualToAnchor:titleView.heightAnchor constant:-4.0].active = true;
    
    profileImageView.layer.cornerRadius = 15;
    profileImageView.clipsToBounds = true;
    profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    if(_currentUser && ![_currentUser.uid isEqualToString:@""])
    {
        if([_currentUser.profileURL isEqualToString:@""])
        {
            profileImageView.image = [UIImage imageNamed:@"default-logo"];
        }
        else
        {
            [[DataProvider sharedInstance] loadProfileImageFromURL:_currentUser.profileURL complitionHandler:^(NSError * _Nonnull error, NSData * _Nonnull imageData)
             {
                 if(!error && imageData)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^
                                    {
                                        self->profileImageView.image = [UIImage imageWithData:imageData];
                                    });
                 }
             }];
        }
    }
    
    UILabel *nameLabel = [UILabel new];
    [titleView addSubview:nameLabel];
    nameLabel.translatesAutoresizingMaskIntoConstraints = false;
    [nameLabel.leftAnchor constraintEqualToAnchor:profileImageView.rightAnchor constant:5].active = true;
    [nameLabel.rightAnchor constraintEqualToAnchor:titleView.rightAnchor].active = true;
    [nameLabel.heightAnchor constraintEqualToAnchor:profileImageView.heightAnchor].active = true;
    [nameLabel.centerYAnchor constraintEqualToAnchor:profileImageView.centerYAnchor].active = true;
    nameLabel.textColor = [UIColor whiteColor];
    if(_currentUser)
    {
        nameLabel.text = _currentUser.name;
    }
    
    self.navigationItem.titleView = titleView;
}

- (void)handleProfileTap
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    
    imagePicker.delegate = self;
    imagePicker.allowsEditing = true;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    UIImage *selectedImage;
    if(info[UIImagePickerControllerEditedImage])
    {
        selectedImage = info[UIImagePickerControllerEditedImage];
    }
    else
    {
        selectedImage = info[UIImagePickerControllerOriginalImage];
    }
    
    [[DataProvider sharedInstance] uploadProfileImage:selectedImage forUser:_currentUser compressionQuality:0.1 complitionHandler:^(NSError * _Nonnull error, UIImage * _Nonnull uploadedImage)
    {
        if(!error && uploadedImage)
        {
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               self->profileImageView.image = uploadedImage;
                           });
        }
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Выход из учетной записи"
                                                                   message:@"Вы действительно хотите выйти из текущей учетной записи ?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Да" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
    {
        [[DataProvider sharedInstance] signOutHandler:^(NSError * _Nonnull error)
         {
             if(error)
             {
                 return;
             }
             
             [self.navigationController popToRootViewControllerAnimated:YES];
         }];
    }];
    
    UIAlertAction *notAction = [UIAlertAction actionWithTitle:@"Нет" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:yesAction];
    [alert addAction:notAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
