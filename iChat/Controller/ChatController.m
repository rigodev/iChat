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
@import MobileCoreServices;

static NSString *const cellId = @"cellId";
static const CGFloat imageWidthStretchRatio = 0.7;
static const CGFloat textWidthStretchRatio = 0.6;

@interface ChatController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MessageCellDelegate>
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
    NSLayoutConstraint *sendContainerBottomAnchor;
    
    CGRect _startingFrame;
    UIImageView *_startingImageView;
    UIView *_backgroundView;
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
    //    self.chatCollectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    sendContainerBottomAnchor = [self.sendContainerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)handleKeyboardDidShow:(NSNotification *)notification
{
    [self scrollToLastMessageWithAnimation:YES];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    sendContainerBottomAnchor.constant = 0;
    
    double keyboardDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:keyboardDuration animations:^
     {
         [self.view layoutIfNeeded];
     }];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification
{CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    sendContainerBottomAnchor.constant = -keyboardFrame.size.height;
    sendContainerBottomAnchor.active = true;
    
    double keyboardDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:keyboardDuration animations:^
     {
         [self.view layoutIfNeeded];
     }];
}

- (IBAction)handleMediaChoose:(id)sender
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    }
    
    imagePicker.delegate = self;
    imagePicker.allowsEditing = true;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    NSString *selectedMediaType = info[UIImagePickerControllerMediaType];
    if([selectedMediaType isEqualToString:(NSString *)kUTTypeImage])
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
        
        [self sendMessageWithImage:selectedImage];
    }
    else if([selectedMediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [self sendMessageWithVideoURL:videoURL];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)performZoomImageView:(UIImageView *)imageView
{
    _startingImageView = imageView;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundViewTapRecognizer:)];
    
    _backgroundView = [UIView new];
    _backgroundView.frame = keyWindow.frame;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0;
    [keyWindow addSubview:_backgroundView];
    
    _startingFrame = [imageView.superview convertRect:imageView.frame toView:nil];
    UIImageView *zoomingImageView = [[UIImageView alloc] initWithFrame:_startingFrame];
    zoomingImageView.image = imageView.image;
    zoomingImageView.userInteractionEnabled = true;
    [zoomingImageView addGestureRecognizer:tapRecognizer];
    [keyWindow addSubview:zoomingImageView];
    
    self->_startingImageView.hidden = true;
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self->_backgroundView.alpha = 1;
         CGFloat zoomingHeight = self->_startingFrame.size.height / self->_startingFrame.size.width * keyWindow.frame.size.width;
         zoomingImageView.frame = CGRectMake(0, 0, keyWindow.frame.size.width, zoomingHeight);
         zoomingImageView.center = keyWindow.center;
     }
                     completion:nil];
}

- (void)handleBackgroundViewTapRecognizer:(UITapGestureRecognizer *)tapRecognizer
{
    UIImageView *zoomingImageView = (UIImageView *)tapRecognizer.view;
    zoomingImageView.layer.cornerRadius = 5;
    zoomingImageView.layer.masksToBounds = true;
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self->_backgroundView.alpha = 0;
         zoomingImageView.frame = self->_startingFrame;
     }
                     completion:^(BOOL finished)
     {
         self->_startingImageView.hidden = false;
         [zoomingImageView removeFromSuperview];
     }];
}

- (void)sendMessageWithText:(NSString *)text
{
    Message *message = [[Message alloc] initTextMessage:text
                                           SenderUserId:_currentUserId
                                         receiverUserId:_contactUserId];
    
    [[DataProvider sharedInstance] sendTextMessage:message withComplitionHandler:^(NSError * _Nonnull error)
     {
         if(!error)
         {
             self.messageField.text = nil;
             [self scrollToLastMessageWithAnimation:YES];
         }
     }];
}

- (void)sendMessageWithImage:(UIImage *)image
{
    Message *message = [[Message alloc] initImageMessageForSenderUserId:_currentUserId
                                                         receiverUserId:_contactUserId
                                                             imageWidth:image.size.width
                                                            imageHeight:image.size.height];
    
    [[DataProvider sharedInstance] sendMessage:message withImage:image compressionQuality:0.5 complitionHandler:^(NSError * _Nonnull error)
     {
         [self scrollToLastMessageWithAnimation:YES];
     }];
}

- (void)sendMessageWithVideoURL:(NSURL *)videoURL
{
    Message *message = [[Message alloc] initVideoMessageForSenderUserId:_currentUserId
                                                         receiverUserId:_contactUserId];
    
    [[DataProvider sharedInstance] sendMessage:message withVideoURL:videoURL complitionHandler:^(NSError * _Nonnull error)
     {
         [self scrollToLastMessageWithAnimation:YES];
     }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
        [self.chatCollectionView scrollToItemAtIndexPath:lastItemPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
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
                 self->_initialScrollDone = YES;
                 [self scrollToLastMessageWithAnimation:NO];
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
    [self handleSend:nil];
    return YES;
}

- (IBAction)handleSend:(id)sender
{
    NSString *messageText = [self.messageField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(![messageText isEqualToString:@""] && _currentUserId && _contactUserId)
    {
        [self sendMessageWithText:messageText];
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
    
    cell.delegate = self;
    
    //    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    //    dateFormatter.dateFormat = @"HH:mm:ss";
    //    cell.detailTextLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970: message.timestamp.doubleValue/1000.0]];
    
    Message *message = _messages[indexPath.row];
    
    switch (message.type)
    {
        case MessageTypeText:
        {
            [self configureCell:cell withMessageTypeText:message];
            break;
        }
        case MessageTypeImage:
        {
            [self configureCell:cell withMessageTypeImage:message];
            break;
        }
        case MessageTypeVideo:
        {
            [self configureCell:cell withMessageTypeVideo:message];
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - setup CELLS for different message types

- (void)configureCell:(MessageCell *)cell withMessageTypeText:(Message *)message
{
    cell.bubbleWidthAnchor.constant = [self calculateFrameForText:message.messageText].width + 20;
    [cell setMessageText:message.messageText];
    [self setupBubbleViewForCell:cell withMessage:message];
    
    [cell setHiddenImageView:true];
    [cell setHiddenTextView:false];
    [cell setHiddenPlayButton:true];
}

- (void)configureCell:(MessageCell *)cell withMessageTypeImage:(Message *)message
{
    cell.bubbleWidthAnchor.constant = self.chatCollectionView.frame.size.width * imageWidthStretchRatio;
    [self setupBubbleViewForCell:cell withMessage:message];
    
    [cell setHiddenImageView:false];
    [cell setHiddenTextView:true];
    [cell setHiddenPlayButton:true];
    
    [[DataProvider sharedInstance] loadImageWithMessage:message complitionHandler:^(NSError * _Nullable error, UIImage * _Nullable image)
     {
         if(!error && image)
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                [cell setImageForMessageImageView:image];
                            });
         }
     }];
}

- (void)configureCell:(MessageCell *)cell withMessageTypeVideo:(Message *)message
{
    cell.bubbleWidthAnchor.constant = self.chatCollectionView.frame.size.width * imageWidthStretchRatio;
    [self setupBubbleViewForCell:cell withMessage:message];
    
    [cell setHiddenImageView:false];
    [cell setHiddenTextView:true];
    [cell setHiddenPlayButton:false];
    
    [[DataProvider sharedInstance] loadVideoSnapshotWithMessage:message complitionHandler:^(NSError * _Nullable error, UIImage * _Nullable image)
     {
         if(!error && image)
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                [cell setImageForMessageImageView:image];
                            });
         }
     }];
}

- (void)setupBubbleViewForCell:(MessageCell *)cell withMessage:(Message *)message
{
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
    
    if(message.type != MessageTypeText)
    {
        [cell setBubbleBackgroundColor:[UIColor whiteColor]];
    }
}

#pragma mark - CollectionViewFlowLayout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = _messages[indexPath.item];
    
    switch (message.type)
    {
        case MessageTypeText:
        {
            CGSize messageFrameSize = [self calculateFrameForText:message.messageText];
            return CGSizeMake(self.chatCollectionView.frame.size.width - 5, messageFrameSize.height + 20);
            break;
        }
        case MessageTypeImage:
        {
            CGSize messageFrameSize = CGSizeMake(self.chatCollectionView.frame.size.width - 5, message.imageHeight / message.imageWidth * (self.chatCollectionView.frame.size.width * imageWidthStretchRatio));
            return messageFrameSize;
            break;
        }
        case MessageTypeVideo:
        {
            CGSize messageFrameSize = CGSizeMake(self.chatCollectionView.frame.size.width - 5, message.imageHeight / message.imageWidth * (self.chatCollectionView.frame.size.width * imageWidthStretchRatio));
            return messageFrameSize;
            break;
        }
    }
}

- (CGSize)calculateFrameForText:(NSString *)text
{
    CGSize size = CGSizeMake(self.view.frame.size.width * textWidthStretchRatio, NSUIntegerMax);
    
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
