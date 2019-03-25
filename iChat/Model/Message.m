//
//  Message.m
//  iChat
//
//  Created by rigo on 24/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "Message.h"
#import "Constants.h"
@import Firebase;

@implementation Message

- (id)initWithSenderUserId:(NSString *)senderUserId receiverUserId:(NSString*)receiverUserId messageText:(NSString *)messageText timestamp:(NSString *)timestamp
{
    if(self = [super init])
    {
        self.senderUserId = senderUserId;
        self.receiverUserId = receiverUserId;
        self.messageText = messageText;
        _timestamp = timestamp;
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{kMessageText : self.messageText,
             kMessageSenderUserId : self.senderUserId,
             kMessageReceiverUserId : self.receiverUserId,
             kMessageTimestamp : FIRServerValue.timestamp
             };
}

@end
