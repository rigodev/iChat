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
@import AVFoundation;

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
    _loggedUser = nil;
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

- (void)fetchCurrentUserWithHandler:(void(^)(User * _Nullable))handler
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


- (void)fetchUserWithId:(NSString *)userId complitionHandler:(void(^)(User *))handler;
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

- (void)fetchContactsWithHandler:(void(^)(NSArray *users))handler
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

- (void)removeContactsObservers
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

- (void)uploadProfileImage:(UIImage *)profileImage forUser:(User *)user compressionQuality:(CGFloat)compressionQuality complitionHandler:(void(^)(NSError *error, UIImage *uploadedImage))handler
{
    if(!profileImage)
    {
        return;
    }
    
    [self uploadImage:profileImage toStoragePath:profileImagesPath compressionQuality:compressionQuality localSaving:false complitionHandler:^(NSError * _Nullable error, NSString * _Nullable imageUID, NSData * _Nullable imageData)
     {
         if(error && ![imageUID isEqualToString:@""])
         {
             handler(error, nil);
             return;
         }
         
         user.profileURL = imageUID;
         FIRDatabaseReference *userRef = [[self->_databaseRef child:usersPath] child:user.uid];
         [userRef updateChildValues:@{kUserProfileImageURL : user.profileURL} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
          {
              if(error)
              {
                  handler(error, nil);
                  return;
              }
              
              handler(nil, [UIImage imageWithData:imageData]);
          }];
     }];
}

- (void)sendMessage:(Message *)message withImage:(UIImage *)uploadingImage compressionQuality:(CGFloat)compressionQuality complitionHandler:(void(^)(NSError *error))handler
{
    if(!uploadingImage || !message.senderUserId || !message.receiverUserId)
    {
        return;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(uploadingImage, compressionQuality);
    NSString *imageNameUID = [NSUUID UUID].UUIDString;
    
    FIRStorageReference *storageRef = [[[FIRStorage storage].reference child:messageImagesPath] child:imageNameUID];
    if (storageRef)
    {
        [storageRef putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error)
         {
             if(error)
             {
                 NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
                 handler(error);
                 return;
             }
             
             if(!metadata || !metadata.path)
             {
                 NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), @"metadata(.path) is nil");
                 NSError *error = [NSError errorWithDomain:NSStringFromSelector(_cmd)
                                                      code:0
                                                  userInfo:@{NSLocalizedDescriptionKey : @"metadata(.path) is nil"}];
                 handler(error);
                 return;
             }
             
             [self saveLocalImageData:imageData withImageName:[metadata.path lastPathComponent]];
             
             message.imageUID = [metadata.path lastPathComponent];
             [self sendMessage:message complitionHandler:^(NSError * _Nonnull error)
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
         }];
    }
    else
    {
        NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), @"FIRStorageReference is nil");
        NSError *error = [NSError errorWithDomain:NSStringFromSelector(_cmd)
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey : @"FIRStorageReference is nil"}];
        handler(error);
        return;
    }
}

- (void)sendMessage:(Message *)message
       withVideoURL:(NSURL*)videoURL
  complitionHandler:(void(^)(NSError *error))handler
{
    if(!videoURL || !message.senderUserId || !message.receiverUserId)
    {
        return;
    }
    
    NSString *videoNameUID = [NSUUID UUID].UUIDString;
    
    FIRStorageReference *storageRef = [[[FIRStorage storage].reference child:messageVideosPath] child:videoNameUID];
    if (!storageRef)
    {
        NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), @"FIRStorageReference is nil");
        NSError *error = [NSError errorWithDomain:NSStringFromSelector(_cmd)
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey : @"FIRStorageReference is nil"}];
        handler(error);
        return;
    }
    
    UIImage *snapshotImage = [self snapshotVideoForFileURL:videoURL];
    if(!snapshotImage)
    {
        NSString *errorMessage = @"could not make SnapshotImage";
        NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), errorMessage);
        NSError *error = [NSError errorWithDomain:NSStringFromSelector(_cmd)
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        handler(error);
        return;
    }
    
    [storageRef putFile:videoURL metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error)
     {
         if(error)
         {
             NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
             handler(error);
             return;
         }
         
         if(!metadata || !metadata.path)
         {
             NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), @"metadata(.path) is nil");
             NSError *error = [NSError errorWithDomain:NSStringFromSelector(_cmd)
                                                  code:0
                                              userInfo:@{NSLocalizedDescriptionKey : @"metadata(.path) is nil"}];
             handler(error);
             return;
         }
         
         message.videoUID = [metadata.path lastPathComponent];
         [self saveLocalVideoURL:videoURL withVideoUID:message.videoUID];
         
         [self uploadImage:snapshotImage toStoragePath:messageVideoSnapshotsPath compressionQuality:0.3 localSaving:true complitionHandler:^(NSError * _Nullable error, NSString * _Nullable snapshotImageUID, NSData * _Nullable imageData)
          {
              if(error)
              {
                  handler(error);
                  return;
              }
              
              message.imageUID = snapshotImageUID;
              message.imageHeight = snapshotImage.size.height;
              message.imageWidth = snapshotImage.size.width;
              [self sendMessage:message complitionHandler:^(NSError * _Nonnull error)
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
          }];
     }];
}

- (void)saveLocalVideoURL:(NSURL *)videoURL withVideoUID:(NSString *)videoUID
{
    NSURL *fileURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:videoUID];
    
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    [videoData writeToURL:fileURL atomically:YES];
}

- (UIImage *)snapshotVideoForFileURL:(NSURL *)videoURL
{
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    
    NSError *error;
    CGImageRef snapshotCGImage = [imageGenerator copyCGImageAtTime:(CMTimeMake(1, 60)) actualTime:nil error:&error];
    
    if(error)
    {
        return nil;
    }
    else
    {
        return [UIImage imageWithCGImage:snapshotCGImage];
    }
}

- (void)uploadImage:(UIImage *)uploadingImage toStoragePath:(NSString *)storagePath compressionQuality:(CGFloat)compressionQuality localSaving:(BOOL)localSaving complitionHandler:(void(^)(NSError * _Nullable error, NSString * _Nullable imageUID, NSData * _Nullable imageData))handler
{
    if(!uploadingImage || !storagePath)
    {
        return;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(uploadingImage, compressionQuality);
    NSString *imageUID = [NSUUID UUID].UUIDString;
    
    FIRStorageReference *storageRef = [[[FIRStorage storage].reference child:storagePath] child:imageUID];
    if (!storageRef)
    {
        NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), @"FIRStorageReference is nil");
        NSError *error = [NSError errorWithDomain:NSStringFromSelector(_cmd)
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey : @"FIRStorageReference is nil"}];
        handler(error, nil, nil);
        return;
    }
    
    [storageRef putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error)
     {
         if(error)
         {
             NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
             handler(error, nil, nil);
             return;
         }
         
         if(!metadata || !metadata.path)
         {
             NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), @"metadata(.path) is nil");
             NSError *error = [NSError errorWithDomain:NSStringFromSelector(_cmd)
                                                  code:0
                                              userInfo:@{NSLocalizedDescriptionKey : @"metadata(.path) is nil"}];
             handler(error, nil, nil);
             return;
         }
         
         NSString *metadataImageUID = [metadata.path lastPathComponent];
         if(localSaving)
         {
             [self saveLocalImageData:imageData withImageName:metadataImageUID];
         }
         handler(nil, metadataImageUID, imageData);
         return;
     }];
}

- (void)loadImageWithMessage:(Message *)message complitionHandler:(void(^)(NSError * _Nullable error, UIImage * _Nullable image))handler
{
    if(!message || !message.imageUID)
    {
        return;
    }
    
    UIImage *messageImage = [self loadLocalImageWithName:[message.imageUID lastPathComponent]];
    if(messageImage)
    {
        handler(nil, messageImage);
        return;
    }
    
    FIRStorageReference *storageRef = [[[FIRStorage storage].reference child:messageImagesPath] child:message.imageUID];
    
    [storageRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error)
     {
         if(error)
         {
             NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
             handler(error, nil);
             return;
         }
         
         [[[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData * _Nullable imageData, NSURLResponse * _Nullable response, NSError * _Nullable error)
           {
               if(error)
               {
                   NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
                   handler(error, nil);
                   return;
               }
               
               if(imageData)
               {
                   [self saveLocalImageData:imageData withImageName:message.imageUID];
                   handler(nil, [UIImage imageWithData:imageData]);
                   return;
               }
               
               handler(nil, nil);
               return;
           }] resume];
     }];
}

- (void)loadVideoSnapshotWithMessage:(Message *)message complitionHandler:(void(^)(NSError * _Nullable error, UIImage * _Nullable image))handler
{
    if(!message || !message.imageUID)
    {
        return;
    }
    
    UIImage *messageImage = [self loadLocalImageWithName:[message.imageUID lastPathComponent]];
    if(messageImage)
    {
        handler(nil, messageImage);
        return;
    }
    
    FIRStorageReference *storageRef = [[[FIRStorage storage].reference child:messageVideoSnapshotsPath] child:message.imageUID];
    [storageRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error)
     {
         if(error)
         {
             NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
             handler(error, nil);
             return;
         }
         
         [[[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData * _Nullable imageData, NSURLResponse * _Nullable response, NSError * _Nullable error)
           {
               if(error)
               {
                   NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
                   handler(error, nil);
                   return;
               }
               
               if(imageData)
               {
                   [self saveLocalImageData:imageData withImageName:message.imageUID];
                   handler(nil, [UIImage imageWithData:imageData]);
                   return;
               }
               
               handler(nil, nil);
               return;
           }] resume];
     }];
}

- (void)saveLocalImageData:(NSData *)imageData withImageName:(NSString *)imageUID
{
    NSURL *fileURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:imageUID];
    
    [imageData writeToURL:fileURL atomically:YES];
}

- (UIImage *)loadLocalImageWithName:(NSString *)imageUID
{
    NSURL *fileURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:imageUID];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path])
    {
        NSData *imageData = [NSData dataWithContentsOfURL:fileURL];
        UIImage *image = [UIImage imageWithData:imageData];
        return image;
    }
    else
    {
        return nil;
    }
}

- (void)fetchURLForVideoUID:(NSString *)videoUID complitionHandler:(void(^)(NSError *error, NSURL *fileURL))handler
{
    if(!videoUID || [videoUID isEqualToString:@""])
    {
        return;
    }
    
    FIRStorageReference *storageRef = [[[FIRStorage storage].reference child:messageVideosPath] child:videoUID];
    [storageRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error)
     {
         if(error)
         {
             NSLog(@"%@ :: %@", NSStringFromSelector(_cmd), error.userInfo[@"NSLocalizedDescription"]);
             handler(error, nil);
             return;
         }
         
         handler(nil, URL);
         return;
     }];
}

- (void)loadProfileImageFromURL:(NSString *)imageURL complitionHandler:(void(^)(NSError *error, NSData *imageData))handler
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
}

- (void)sendTextMessage:(Message *)message withComplitionHandler:(void(^)(NSError *error))handler
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
    
    [self sendMessage:(Message *)message complitionHandler:(void(^)(NSError *error))handler];
}

- (void)sendMessage:(Message *)message complitionHandler:(void(^)(NSError *error))handler
{
    if([message.receiverUserId isEqualToString:message.senderUserId])
    {
        FIRDatabaseReference *messageSenderRef = [[[[_databaseRef child:chatsPath] child:message.senderUserId] child:message.receiverUserId] childByAutoId];
        
        // update Sender=Receiver chat
        [messageSenderRef updateChildValues:[message dictionaryRepresentation] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
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
    else
    {
        // update Sender chat
        dispatch_async(dispatch_get_main_queue(),^{
            FIRDatabaseReference *messageSenderRef = [[[[self->_databaseRef child:chatsPath] child:message.senderUserId] child:message.receiverUserId] childByAutoId];
            [messageSenderRef updateChildValues:[message dictionaryRepresentation] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
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
        });
        
        // update Receiver chat
        dispatch_async(dispatch_get_main_queue(), ^{
            FIRDatabaseReference *messageReceiverRef = [[[[self->_databaseRef child:chatsPath] child:message.receiverUserId] child:message.senderUserId] childByAutoId];
            [messageReceiverRef updateChildValues:[message dictionaryRepresentation] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
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
        });
    }
}


- (void)observeChatsForUserId:(NSString *)userId withComplitionHandler:(void(^)(NSArray *messages))handler
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        handler(nil);
        return;
    }
    
    FIRDatabaseReference *userChatsRef = [[_databaseRef child:chatsPath] child:userId];
    [userChatsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         NSMutableArray *messagesArray = [NSMutableArray array];
         for(FIRDataSnapshot *snap in [[snapshot children] allObjects])
         {
             NSString *contactId = snap.key;
             NSArray *sortedMessageArray = [[snap.value allObjects]
                                            sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull message1, id  _Nonnull message2)
             {
                 return [[message1 valueForKey:kMessageTimestamp] doubleValue] > [[message2 valueForKey:kMessageTimestamp] doubleValue];
             }];
             
             Message *lastContactMessage = [[Message alloc] initWithDictionaryRepresentation:[sortedMessageArray lastObject]];
             NSDictionary *contactIDWithMessage = @{kContactId : contactId,
                                                    kLastContactMessage : lastContactMessage};
             
             [messagesArray addObject:contactIDWithMessage];
         }
         
         handler(messagesArray);
     }];
}

- (void)removeChatsObservingForUserId:(NSString *)userId
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        return;
    }
    
    FIRDatabaseReference *userChatsRef = [[_databaseRef child:chatsPath] child:userId];
    [userChatsRef removeAllObservers];
}

- (void)observeChatForUserId:(NSString *)userId withContactUserId:(NSString *)contactUserId WithComplitionHandler:(void(^)(NSArray *messages))handler
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        handler(nil);
        return;
    }
    
    FIRDatabaseReference *userChatRef = [[[_databaseRef child:chatsPath] child:userId] child:contactUserId];
    [userChatRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         NSMutableArray *messagesArray = [NSMutableArray array];
         for(FIRDataSnapshot *snap in [[snapshot children] allObjects])
         {
             Message *message = [[Message alloc] initWithDictionaryRepresentation:snap.value];
             [messagesArray addObject:message];
         }
         
         handler(messagesArray);
     }];
}

- (void)removeChatObservingForUserId:(NSString *)userId withContactUserId:(NSString *)contactUserId
{
    if(_databaseRef == nil)
    {
        NSLog(@"%@ :: FIRDatabaseReference is nil", NSStringFromSelector(_cmd));
        return;
    }
    
    FIRDatabaseReference *userChatWithContactRef = [[[_databaseRef child:chatsPath] child:userId] child:contactUserId];
    [userChatWithContactRef removeAllObservers];
}

@end
