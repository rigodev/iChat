//
//  Message.h
//  iChat
//
//  Created by rigo on 24/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MessageTypeText,
    MessageTypeImage,
    MessageTypeVideo
} MessageType;

@interface Message : NSObject

@property (assign, nonatomic) MessageType type;
@property (nonatomic, copy, nullable) NSString *messageText;
@property (nonatomic, copy, nonnull) NSString *senderUserId;
@property (nonatomic, copy, nonnull) NSString *receiverUserId;
@property (nonatomic, copy, nullable) NSNumber *timestamp;
@property (nonatomic, copy, nullable) NSString *imageUID;
@property (nonatomic, copy, nullable) NSString *videoUID;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) CGFloat imageWidth;

- (id)initTextMessage:(NSString *)messageText
         SenderUserId:(NSString *)senderUserId
       receiverUserId:(NSString *)receiverUserId;

- (id)initImageMessageForSenderUserId:(NSString *)senderUserId
                       receiverUserId:(NSString *)receiverUserId
                           imageWidth:(CGFloat)imageWidth
                          imageHeight:(CGFloat)imageHeight;

- (id)initVideoMessageForSenderUserId:(NSString *)senderUserId
                       receiverUserId:(NSString *)receiverUserId;

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation;

- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
