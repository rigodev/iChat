//
//  DataProvider.h
//  iChat
//
//  Created by rigo on 19/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class User;

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
- (void)fetchUserContactsWithHandler:(void(^)(NSArray *users))handler;
- (void)uploadImage:(NSData *)imageData complitionHandler:(void(^)(NSError *error, NSString *imageURLString))handler;
- (void)removeUserContactsObservers;
- (void)getProfileImageFromURL:(NSString *)imageURL complitionHandler:(void(^)(NSError *error, NSData *imageData))handler;

@end

NS_ASSUME_NONNULL_END
