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
@property (nonatomic, copy, readonly) NSString *timestamp;

- (NSDictionary *)dictionaryRepresentation;
- (id)initWithSenderUserId:(NSString *)senderUserId receiverUserId:(NSString*)receiverUserId messageText:(NSString *)messageText timestamp:(NSString *)timestamp;

@end

NS_ASSUME_NONNULL_END
