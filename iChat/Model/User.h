//
//  User.h
//  iChat
//
//  Created by rigo on 21/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy, nullable) NSString *profileURL;

- (id)initWithName:(NSString *)name email:(NSString *)email uid:(nullable NSString *)uid profileURL:(nullable NSString *)profileURL;
- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
