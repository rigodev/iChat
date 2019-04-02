//
//  DataProvider.h
//  iChat
//
//  Created by rigo on 19/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class User, Message;

@interface DataProvider : NSObject

+ (instancetype)sharedInstance;

- (void)signupUserWithName:(NSString *)name
                     email:(NSString *)email
                  password:(NSString *)password
                   handler:(void (^)(NSError *error))handler;

- (void)signinUserWithEmail:(NSString *)email
                   password:(NSString *)password
                    handler:(void (^)(NSError *error))handler;

- (void)currentUserAuthorizedHandler:(void(^)(BOOL authorized, NSError *error))handler;
- (void)signOutHandler:(void(^)(NSError *error))handler;
- (void)fetchCurrentUserWithHandler:(void(^)(User *user))handler;
- (void)fetchContactsWithHandler:(void(^)(NSArray *users))handler;

- (void)sendTextMessage:(Message *)message withComplitionHandler:(void(^)(NSError *error))handler;

- (void)sendMessage:(Message *)message
          withImage:(UIImage *)uploadingImage
 compressionQuality:(CGFloat)compressionQuality
  complitionHandler:(void(^)(NSError *error))handler;

- (void)sendMessage:(Message *)message
       withVideoURL:(NSURL*)videoURL
  complitionHandler:(void(^)(NSError *error))handler;

- (void)loadImageWithMessage:(Message *)message complitionHandler:(void(^)(NSError * _Nullable error, UIImage * _Nullable image))handler;

- (void)loadVideoSnapshotWithMessage:(Message *)message complitionHandler:(void(^)(NSError * _Nullable error, UIImage * _Nullable image))handler;

- (void)removeContactsObservers;
- (void)downloadProfileImageFromURL:(NSString *)imageURL complitionHandler:(void(^)(NSError *error, NSData *imageData))handler;
- (nullable NSString *)getCurrentUserId;

- (void)observeChatsForUserId:(NSString *)userId withComplitionHandler:(void(^)(NSArray *messages))handler;
- (void)removeChatsObservingForUserId:(NSString *)userId;
- (void)observeChatForUserId:(NSString *)userId withContactUserId:(NSString *)contactUserId WithComplitionHandler:(void(^)(NSArray *messages))handler;
- (void)removeChatObservingForUserId:(NSString *)userId withContactUserId:(NSString *)contactUserId;

@end

NS_ASSUME_NONNULL_END
