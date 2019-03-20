//
//  DataProvider.h
//  iChat
//
//  Created by rigo on 19/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataProvider : NSObject

+ (instancetype)sharedInstance;

- (void)registrUserName:(NSString *)name
                  email:(NSString *)email
               password:(NSString *)password
                handler:(void (^)(NSError *error))handler;

- (void)currentUserAuthorizedHandler:(void(^)(BOOL authorized, NSError *error))handler;
- (void)signOutHandler:(void(^)(NSError *error))handler;

@end

NS_ASSUME_NONNULL_END
