//
//  Constants.h
//  iChat
//
//  Created by rigo on 21/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

// internal keys
static NSString *const kUserId = @"uid";
static NSString *const kContactId = @"contactUID";
static NSString *const kLastContactMessage = @"lastContactMessage";

// FireBase paths from root
static NSString *const usersPath = @"users";
static NSString *const chatsPath = @"chats";

// FireBase root/[usersPath]/[userID]/
static NSString *const kUserName = @"name";
static NSString *const kUserEmail = @"email";
static NSString *const kUserProfileImageURL = @"profileImageURL";

// FireBase root/[chatsPath]/[senderID]/[receiverID]/[messageId]/
static NSString *const kMessageType = @"type";
static NSString *const kMessageText = @"text";
static NSString *const kMessageSenderUserId = @"senderUserId";
static NSString *const kMessageReceiverUserId = @"receiverUserId";
static NSString *const kMessageImageUID = @"imageUID";
static NSString *const kMessageVideoUID = @"videoUID";
static NSString *const kMessageImageWidth = @"imageWidth";
static NSString *const kMessageImageHeight = @"imageHeight";
static NSString *const kMessageTimestamp = @"timestamp";

// FireStorage paths from root
static NSString *const profileImagesPath = @"profile_images";
static NSString *const messageImagesPath = @"message_images";
static NSString *const messageVideosPath = @"message_videos";
static NSString *const messageVideoSnapshotsPath = @"message_videosnapshots";

#endif /* Constants_h */
