//
//  User.m
//  iChat
//
//  Created by rigo on 21/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import "User.h"
#import "Constants.h"

@implementation User

- (id)initWithName:(NSString *)name email:(NSString *)email uid:(NSString *)uid profileURL:(NSString *)profileURL
{
    if(self = [super init])
    {
        self.name = name;
        self.email = email;
        self.uid = uid;
        self.profileURL = profileURL;
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSString *profileURLString = (self.profileURL == nil) ? @"" : self.profileURL;
    
    return @{kUserName : self.name,
             kUserEmail : self.email,
             kUserProfileImageURL : profileURLString};
}

@end
