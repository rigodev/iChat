//
//  Message.m
//  iChat
//
//  Created by rigo on 24/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import "Message.h"
#import "Constants.h"
@import Firebase;

@interface Message ()

- (id)initWithType:(MessageType)type
      SenderUserId:(NSString *)senderUserId
    receiverUserId:(NSString *)receiverUserId
       messageText:(nullable NSString *)messageText
          imageUID:(nullable NSString *)imageUID
          videoUID:(nullable NSString *)videoUID
        imageWidth:(CGFloat)imageWidth
       imageHeight:(CGFloat)imageHeight
         timestamp:(nullable NSNumber *)timestamp;

@end

@implementation Message

- (id)initWithType:(MessageType)type
      SenderUserId:(NSString *)senderUserId
    receiverUserId:(NSString *)receiverUserId
       messageText:(nullable NSString *)messageText
          imageUID:(nullable NSString *)imageUID
          videoUID:(nullable NSString *)videoUID
        imageWidth:(CGFloat)imageWidth
       imageHeight:(CGFloat)imageHeight
         timestamp:(nullable NSNumber *)timestamp
{
    if(self = [super init])
    {
        self.type = type;
        self.senderUserId = senderUserId;
        self.receiverUserId = receiverUserId;
        self.messageText = messageText;
        self.imageUID = imageUID;
        self.videoUID = videoUID;
        self.timestamp = timestamp;
        self.imageHeight = imageHeight;
        self.imageWidth = imageWidth;
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSString *text = _messageText ? _messageText : @"";
    NSString *imageNameUID = _imageUID ? _imageUID : @"";
    NSString *videoNameUID = _videoUID ? _videoUID : @"";
    
    return @{kMessageType : [NSNumber numberWithUnsignedInteger: self.type],
             kMessageText : text,
             kMessageImageUID : imageNameUID,
             kMessageVideoUID : videoNameUID,
             kMessageSenderUserId : self.senderUserId,
             kMessageReceiverUserId : self.receiverUserId,
             kMessageImageWidth : [NSNumber numberWithFloat:self.imageWidth],
             kMessageImageHeight : [NSNumber numberWithFloat:self.imageHeight],
             kMessageTimestamp : FIRServerValue.timestamp
             };
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation
{
    return [self initWithType:[dictionaryRepresentation[kMessageType] unsignedIntegerValue]
                 SenderUserId:dictionaryRepresentation[kMessageSenderUserId]
               receiverUserId:dictionaryRepresentation[kMessageReceiverUserId]
                  messageText:dictionaryRepresentation[kMessageText]
                     imageUID:dictionaryRepresentation[kMessageImageUID]
                     videoUID:dictionaryRepresentation[kMessageVideoUID]
                   imageWidth:[dictionaryRepresentation[kMessageImageWidth] floatValue]
                  imageHeight:[dictionaryRepresentation[kMessageImageHeight] floatValue]
                    timestamp:dictionaryRepresentation[kMessageTimestamp]];
}

- (id)initTextMessage:(NSString *)messageText
         SenderUserId:(NSString *)senderUserId
       receiverUserId:(NSString *)receiverUserId
{
    return [self initWithType:MessageTypeText
                 SenderUserId:senderUserId
               receiverUserId:receiverUserId
                  messageText:messageText
                     imageUID:nil
                     videoUID:nil
                   imageWidth:0
                  imageHeight:0
                    timestamp:nil];
}

- (id)initImageMessageForSenderUserId:(NSString *)senderUserId
                       receiverUserId:(NSString *)receiverUserId
                           imageWidth:(CGFloat)imageWidth
                          imageHeight:(CGFloat)imageHeight
{
    return [self initWithType:MessageTypeImage
                 SenderUserId:senderUserId
               receiverUserId:receiverUserId
                  messageText:nil
                     imageUID:nil
                     videoUID:nil
                   imageWidth:imageWidth
                  imageHeight:imageHeight
                    timestamp:nil];
}

- (id)initVideoMessageForSenderUserId:(NSString *)senderUserId
                       receiverUserId:(NSString *)receiverUserId
{
    return [self initWithType:MessageTypeVideo
                 SenderUserId:senderUserId
               receiverUserId:receiverUserId
                  messageText:nil
                     imageUID:nil
                     videoUID:nil
                   imageWidth:0
                  imageHeight:0
                    timestamp:nil];
}

@end
