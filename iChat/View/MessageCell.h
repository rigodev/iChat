//
//  MessageCell.h
//  iChat
//
//  Created by rigo on 25/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MessageCellDelegate <NSObject>

- (void)performZoomImageView:(UIImageView *)imageView;

@end

@interface MessageCell : UICollectionViewCell

@property (nonatomic, weak) id <MessageCellDelegate> delegate;

- (void)setMessageText:(NSString *)text;
- (void)setBubbleBackgroundColor:(UIColor *)color;

- (void)setHiddenPlayButton:(BOOL)hidden;
- (void)setHiddenImageView:(BOOL)hidden;
- (void)setHiddenTextView:(BOOL)hidden;
- (void)setImageForMessageImageView:(UIImage *)image;

@property (nonatomic, strong) NSLayoutConstraint *bubbleWidthAnchor, *bubbleRightAnchor, *bubbleLeftAnchor;
@property (nonatomic, strong, readonly) UIColor *blueBubbleColor, *greyBubbleColor;

@end


NS_ASSUME_NONNULL_END
