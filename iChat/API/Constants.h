//
//  Constants.h
//  iChat
//
//  Created by rigo on 21/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

// FireBase paths from root
static NSString *const usersPath = @"users";
static NSString *const messagesPath = @"messages";

// FireBase root/[usersPath]/[userID]/
static NSString *const kUserName = @"name";
static NSString *const kUserEmail = @"email";
static NSString *const kUserProfileImageURL = @"profileImageURL";

// FireBase root/[messagesPath]/[messageId]/
static NSString *const kMessageText = @"text";
static NSString *const kMessageSenderUserId = @"senderUserId";
static NSString *const kMessageReceiverUserId = @"receiverUserId";
static NSString *const kMessageTimestamp = @"timestamp";

// FireStorage paths from root
static NSString *const profileImagesPath = @"profile_images";

#endif /* Constants_h */
