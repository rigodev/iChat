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
#import "MessageCell.h"

static NSString *const cellId = @"cellId";

@interface ChatController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    User *_receiverUser;
    NSString *_currentUserId, *_contactUserId;
    NSArray *_messages;
}

@property (weak, nonatomic) IBOutlet UICollectionView *chatCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UIView *sendContainerView;

@end

@implementation ChatController
{
    BOOL _initialScrollDone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentUserId = [[DataProvider sharedInstance] getCurrentUserId];
    [self setupChatViews];
    [self setupKeyboardObservers];
}

- (void)setupChatViews
{
    _initialScrollDone = NO;
    self.chatCollectionView.alwaysBounceVertical = true;
    self.messageField.delegate = self;
}

- (void)setupKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    NSLog(@"frame = %f", self.sendContainerView.frame.size.height);
    [self.sendContainerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = true;
    NSLog(@"frame = %f", self.sendContainerView.frame.size.height);
}

- (void)handleKeyboardWillShow:(NSNotification *)notification
{
    NSLog(@"frame = %f", self.sendContainerView.frame.size.height);
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.sendContainerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:- keyboardFrame.size.height].active = true;
    NSLog(@"frame = %f", self.sendContainerView.frame.size.height);
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

- (void)scrollToLastMessageWithAnimation:(BOOL)animated
{
    if(self->_messages.count > 0)
    {
        NSIndexPath *lastItemPath = [NSIndexPath indexPathForItem:self->_messages.count - 1 inSection:0];
        [self.chatCollectionView scrollToItemAtIndexPath:lastItemPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
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
             [self.chatCollectionView reloadData];
             
             if(!self->_initialScrollDone)
             {
                 [self scrollToLastMessageWithAnimation:NO];
                 self->_initialScrollDone = YES;
             }
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
                 self.messageField.text = nil;
                 [self scrollToLastMessageWithAnimation:YES];
             }
         }];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.chatCollectionView.collectionViewLayout invalidateLayout];
}

- (void)setReceiverUser:(User *)receiverUser;
{
    _receiverUser = receiverUser;
    _contactUserId = receiverUser.uid;
}

#pragma mark - CollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _messages.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    Message *message = _messages[indexPath.row];
    //    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    //    dateFormatter.dateFormat = @"HH:mm:ss";
    //    cell.detailTextLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970: message.timestamp.doubleValue/1000.0]];
    
    cell.bubbleWidthAnchor.constant = [self calculateFrameForText:message.messageText].width + 20;
    [cell setMessageText:message.messageText];
        
    NSLog(@"%@", message.messageText);
    
    
    if([message.senderUserId isEqualToString:_currentUserId])
    {
        [cell setBubbleBackgroundColor:cell.blueBubbleColor];
        cell.bubbleRightAnchor.active = true;
        cell.bubbleLeftAnchor.active = false;
    }
    else
    {
        [cell setBubbleBackgroundColor:cell.greyBubbleColor];
        cell.bubbleRightAnchor.active = false;
        cell.bubbleLeftAnchor.active = true;
    }
    
    
    return cell;
}

#pragma mark - CollectionViewFlowLayout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = _messages[indexPath.item];
    CGSize messageFrameSize = [self calculateFrameForText:message.messageText];
    return CGSizeMake(self.chatCollectionView.frame.size.width - 5, messageFrameSize.height + 20);
}

- (CGSize)calculateFrameForText:(NSString *)text
{
    CGSize size = CGSizeMake(200, NSUIntegerMax);
    
    CGRect textRect = [text boundingRectWithSize:size
                                         options:(NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}
                                         context:nil];
    return textRect.size;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
