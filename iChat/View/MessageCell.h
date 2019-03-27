//
//  MessageCell.h
//  iChat
//
//  Created by rigo on 25/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageCell : UICollectionViewCell

- (void)setMessageText:(NSString *)text;
- (void)setBubbleBackgroundColor:(UIColor *)color;

@property (nonatomic, strong) NSLayoutConstraint *bubbleWidthAnchor, *bubbleRightAnchor, *bubbleLeftAnchor;
@property (nonatomic, strong, readonly) UIColor *blueBubbleColor, *greyBubbleColor;

@end

NS_ASSUME_NONNULL_END
