//
//  Message.h
//  iChat
//
//  Created by rigo on 24/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSObject

@property (nonatomic, copy, nonnull) NSString *messageText;
@property (nonatomic, copy, nonnull) NSString *senderUserId;
@property (nonatomic, copy, nonnull) NSString *receiverUserId;

- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
