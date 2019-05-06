//
//  ChatController.h
//  iChat
//
//  Created by rigo on 23/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class User;

@interface ChatController : UIViewController

- (void)setReceiverUser:(User *)receiverUser;

@end

NS_ASSUME_NONNULL_END
