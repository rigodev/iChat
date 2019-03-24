//
//  Message.m
//  iChat
//
//  Created by rigo on 24/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "Message.h"
#import "Constants.h"

@implementation Message

- (NSDictionary *)dictionaryRepresentation
{
    return @{kMessageText : self.messageText,
             kMessageSenderUserId : self.senderUserId,
             kMessageReceiverUserId : self.receiverUserId
             };
}

@end
