//
//  DataProvider.m
//  iChat
//
//  Created by rigo on 19/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "DataProvider.h"
@import Firebase;

static NSString *const kUserID = @"uid";

@implementation DataProvider
{
    FIRDatabaseReference *_databaseRef, *_curUserRef;
}

+ (instancetype)sharedInstance
{
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init{
    if(self = [super init]){
        _databaseRef = [[FIRDatabase database] reference];
    }
    
    return self;
}

- (void)registrUserName:(NSString *)name
                  email:(NSString *)email
               password:(NSString *)password
                handler:(void (^)(NSError *error))handler
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        return;
    }
    
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([email isEqualToString:@""] || [password isEqualToString:@""])
    {
        NSLog(@"%@ :: email and password can't be empty", NSStringFromSelector(_cmd));
        return;
    }
    
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        return;
    }
    
    [[FIRAuth auth] createUserWithEmail:email password:password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error)
     {
         if(error)
         {
             NSLog(@"%@ :: FIRAuth createUserWithEmail error = %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
             handler(error);
             return;
         }
         
         NSString *userID = authResult.user.uid;
         [[NSUserDefaults standardUserDefaults] setValue:userID forKey:kUserID];
         self->_curUserRef = [[self->_databaseRef child:@"users"] child:userID];
         
         NSDictionary *user = @{@"name" : name,
                                @"email" : email};
         [self->_curUserRef setValue:user];
         handler(nil);
     }];
}

- (void)currentUserAuthorizedHandler:(void(^)(BOOL authorized, NSError *error))handler
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        handler(false, nil);
        return;
    }
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:kUserID];
    if(userID == nil)
    {
        handler(false, nil);
        return;
    }
    
    FIRUser *user = [[FIRAuth auth] currentUser];
    if(user == nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kUserID];
        handler(false, nil);
        return;
    }
    
    if(![userID isEqualToString:user.uid])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kUserID];
        NSLog(@"%@ :: different current users", NSStringFromSelector(_cmd));
        
        NSError *error;
        [[FIRAuth auth] signOut:&error];
        if(error)
        {
            NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
        }
        
        handler(false, nil);
        return;
    }
    else
    {
        _curUserRef = [[_databaseRef child:@"users"] child:userID];
        handler(true, nil);
    }
}

- (void)signOutHandler:(void(^)(NSError *error))handler
{
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    if(error)
    {
        NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
        handler(error);
        return;
    }
    else
    {
        _curUserRef = nil;
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kUserID];
        handler(nil);
        return;
    }
}

@end
