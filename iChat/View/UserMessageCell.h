//
//  UserMessageCell.h
//  iChat
//
//  Created by rigo on 04/04/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserMessageCell : UITableViewCell

- (void)setAvatarImage:(UIImage * _Nonnull)avatarImage;
- (void)setTextNameLabel:(NSString * _Nonnull)text;
- (void)setTextMessageLabel:(NSString * _Nonnull)text;
- (void)setMessageDateTime:(NSNumber * _Nonnull)dateTime;

- (void)resetCellConfiguration;

@end

NS_ASSUME_NONNULL_END
