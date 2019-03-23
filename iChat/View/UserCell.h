//
//  UserCell.h
//  iChat
//
//  Created by rigo on 21/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UITableViewCell

- (void)setNameText:(NSString *)name;
- (void)setAvatarImage:(UIImage *)image;
- (void)configureDefaultCellView;

@end

NS_ASSUME_NONNULL_END
