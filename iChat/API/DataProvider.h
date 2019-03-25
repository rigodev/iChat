//
//  DataProvider.h
//  iChat
//
//  Created by rigo on 19/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import <Foundation/Foundation.h>

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
- (void)uploadImage:(NSData *)imageData complitionHandler:(void(^)(NSError *error, NSString *imageURLString))handler;
- (void)removeContactsObservers;
- (void)getProfileImageFromURL:(NSString *)imageURL complitionHandler:(void(^)(NSError *error, NSData *imageData))handler;
- (nullable NSString *)getCurrentUserId;
- (void)sendMessage:(Message *)message withComplitionHandler:(void(^)(NSError *error))handler;
- (void)observeChatsForUserId:(NSString *)userId withComplitionHandler:(void(^)(NSArray *messages))handler;
- (void)removeChatsObservingForUserId:(NSString *)userId;
- (void)observeChatForUserId:(NSString *)userId withContactUserId:(NSString *)contactUserId WithComplitionHandler:(void(^)(NSArray *messages))handler;
- (void)removeChatObservingForUserId:(NSString *)userId withContactUserId:(NSString *)contactUserId;

@end

NS_ASSUME_NONNULL_END
