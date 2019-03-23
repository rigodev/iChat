//
//  Constants.h
//  iChat
//
//  Created by rigo on 21/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

// FireBase paths
static NSString *const usersPath = @"users"; // root/

// FireBase root/[usersPath]/[userID]/
static NSString *const kUserName = @"name";
static NSString *const kUserEmail = @"email";
static NSString *const kUserProfileImageURL = @"profileImageURL";

// FireStorage paths
static NSString *const profileImagesPath = @"profile_images"; // root/

#endif /* Constants_h */
