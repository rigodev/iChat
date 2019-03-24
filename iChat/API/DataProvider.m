//
//  DataProvider.m
//  iChat
//
//  Created by rigo on 19/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "DataProvider.h"
#import "User.h"
#import "Constants.h"
#import "Message.h"
@import Firebase;

static NSString *const kUserId = @"uid";

@implementation DataProvider
{
    FIRDatabaseReference *_databaseRef;
    NSCache *_imageCache;
    User *_loggedUser;
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
        _imageCache = [NSCache new];
        _loggedUser = nil;
    }
    
    return self;
}

- (nullable NSString *)getCurrentUserId
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kUserId];
}

- (void)setCurrentUserId:(nullable NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:kUserId];
}

- (void)signupUserWithName:(NSString *)name
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
    
    @try
    {
        [[FIRAuth auth] createUserWithEmail:email password:password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error)
         {
             if(error)
             {
                 NSLog(@"%@ :: FIRAuth createUserWithEmail error = %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
                 handler(error);
                 return;
             }
             
             User *newUser = [[User alloc] initWithName:name email:email uid:authResult.user.uid profileURL:nil];
             [[[self->_databaseRef child:usersPath] child:newUser.uid] setValue:[newUser dictionaryRepresentation] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
              {
                  if(error)
                  {
                      NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
                      handler(error);
                      return;
                  }
                  
                  [self setCurrentUserId:newUser.uid];
                  handler(nil);
              }];
         }];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)currentUserAuthorizedHandler:(void(^)(BOOL authorized, NSError *error))handler
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        handler(false, nil);
        return;
    }
    
    NSString *userId = [self getCurrentUserId];
    if(userId == nil)
    {
        handler(false, nil);
        return;
    }
    
    FIRUser *user = [[FIRAuth auth] currentUser];
    if(user == nil)
    {
        [self setCurrentUserId:nil];
        handler(false, nil);
        return;
    }
    
    if(![userId isEqualToString:user.uid])
    {
        [self setCurrentUserId:nil];
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
        handler(true, nil);
    }
}

- (void)fetchCurrentUserWithHandler:(void(^)(User *))handler
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        handler(nil);
        return;
    }
    
    NSString *userId = [self getCurrentUserId];
    if(userId == nil)
    {
        handler(nil);
        return;
    }
    
    [self fetchUserWithId:userId complitionHandler:handler];
}


- (void)fetchUserWithId:(NSString *)userId complitionHandler:(void(^)(User *))handler
{
    if(userId == nil)
    {
        NSLog(@"%@ :: userId is nil", NSStringFromSelector(_cmd));
        handler(nil);
        return;
    }
    
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        handler(nil);
        return;
    }
    
    [[[_databaseRef child:usersPath] child: userId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if(snapshot.childrenCount == 0)
         {
             handler(nil);
             return;
         }
         
         User *user = [[User alloc] initWithName:snapshot.value[kUserName]
                                           email:snapshot.value[kUserEmail]
                                             uid:userId
                                      profileURL:snapshot.value[kUserProfileImageURL]];
         handler(user);
         return;
     }];
}

- (void)fetchUserContactsWithHandler:(void(^)(NSArray *users))handler
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        handler(nil);
        return;
    }
    
    NSString *userId = [self getCurrentUserId];
    if(userId == nil)
    {
        handler(nil);
        return;
    }
    
    [[_databaseRef child:usersPath] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         NSMutableArray *usersArray = [NSMutableArray array];
         
         for(FIRDataSnapshot *snap in [[snapshot children] allObjects])
         {
             User *user = [[User alloc] initWithName:snap.value[kUserName]
                                               email:snap.value[kUserEmail]
                                                 uid:snap.key
                                          profileURL:snap.value[kUserProfileImageURL]];
             [usersArray addObject:user];
         }
         
         handler(usersArray);
     }];
}

- (void)removeUserContactsObservers
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        return;
    }
    
    [[_databaseRef child:usersPath] removeAllObservers];
}

- (void)signinUserWithEmail:(NSString *)email
                   password:(NSString *)password
                    handler:(void (^)(NSError *error))handler
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        handler(nil);
        return;
    }
    
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error)
     {
         if(error)
         {
             NSLog(@"%@ :: FIRAuth signInWithEmail error = %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
             handler(error);
             return;
         }
         
         NSString *userId = authResult.user.uid;
         [self setCurrentUserId:userId];
         handler(nil);
     }];
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
        [self setCurrentUserId:nil];
        handler(nil);
        return;
    }
}

- (void)uploadImage:(NSData *)imageData complitionHandler:(void(^)(NSError *error, NSString *imageURLString))handler
{
    NSString *nameUID = [NSUUID UUID].UUIDString;
    
    FIRStorageReference *storageRef = [[[FIRStorage storage].reference child:profileImagesPath] child:nameUID];
    if (storageRef)
    {
        [storageRef putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error)
         {
             if(error)
             {
                 NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
                 handler(error, nil);
                 return;
             }
             
             handler(nil, metadata.path);
             return;
         }];
    }
    else
    {
        NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), @"FIRStorageReference is nil");
        NSError *error = [NSError errorWithDomain:NSStringFromSelector(_cmd)
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey : @"FIRStorageReference is nil"}];
        handler(error, nil);
        return;
    }
}

- (void)getProfileImageFromURL:(NSString *)imageURL complitionHandler:(void(^)(NSError *error, NSData *imageData))handler
{
    if([imageURL isEqualToString:@""])
    {
        return;
    }
    
    NSData *imageCacheData = [_imageCache objectForKey:imageURL];
    if(imageCacheData)
    {
        handler(nil, imageCacheData);
        return;
    }
    
    FIRStorageReference *storageRef = [[[FIRStorage storage].reference child:profileImagesPath] child:imageURL];
    
    [storageRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error)
     {
         if(error)
         {
             NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
             handler(error, nil);
             return;
         }
         
         [[[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
           {
               if(error)
               {
                   NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
                   handler(error, nil);
                   return;
               }
               
               [self->_imageCache setObject:data forKey:imageURL];
               handler(nil, data);
               return;
           }] resume];
     }];
    
    //    NSURL *documentsURLPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    //    NSURL *fileURLPath = [documentsURLPath URLByAppendingPathComponent:imageURL];
    
    
    //    FIRStorageReference *storageRef = [[[FIRStorage storage].reference child:profileImagesPath] child:imageURL];
    //    if (storageRef)
    //    {
    //        [storageRef writeToFile:fileURLPath completion:^(NSURL * _Nullable URL, NSError * _Nullable error)
    //        {
    //            if(error)
    //            {
    //                NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
    //                handler(error, nil);
    //                return;
    //            }
    //
    //            NSData *imageData = [NSData dataWithContentsOfURL:fileURLPath];
    //            handler(nil, imageData);
    //            return;
    //        }];
    //    }
    //    else
    //    {
    //        NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), @"FIRStorageReference is nil");
    //        NSError *error = [NSError errorWithDomain:NSStringFromSelector(_cmd)
    //                                             code:0
    //                                         userInfo:@{NSLocalizedDescriptionKey : @"FIRStorageReference is nil"}];
    //        handler(error, nil);
    //        return;
    //    }
}

- (void)sendMessage:(Message *)message withComplitionHandler:(void(^)(NSError *error))handler
{
    if(!message.messageText || !message.senderUserId || !message.receiverUserId)
    {
        return;
    }
    
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        handler(nil);
        return;
    }
    
    FIRDatabaseReference *messageRef = [[_databaseRef child:messagesPath] childByAutoId];
    
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionaryWithDictionary: [message dictionaryRepresentation]];
    [messageDict setValue: [NSNumber numberWithInteger:[NSDate date].timeIntervalSince1970] forKey:kMessageTimestamp];
    [messageRef updateChildValues:messageDict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
     {
         if(error)
         {
             NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
             handler(error);
             return;
         }
         
         handler(nil);
         return;
     }];
}

@end
