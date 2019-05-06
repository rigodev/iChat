//
//  MessageCell.h
//  iChat
//
//  Created by rigo on 25/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@protocol MessageCellDelegate;

@interface MessageCell : UICollectionViewCell

@property (nonatomic, weak) id <MessageCellDelegate> delegate;
@property (nonatomic, strong, nullable) NSString *videoUID;

- (void)setMessageText:(NSString *)text;
- (void)setBubbleBackgroundColor:(UIColor *)color;
- (void)setupPlayerLayer:(AVPlayerLayer *)playerLayer;

- (void)setHiddenPlayButton:(BOOL)hidden;
- (void)setHiddenImageView:(BOOL)hidden;
- (void)setHiddenTextView:(BOOL)hidden;
- (void)setImageForMessageImageView:(UIImage *)image;

@property (nonatomic, strong) NSLayoutConstraint *bubbleWidthAnchor, *bubbleRightAnchor, *bubbleLeftAnchor;
@property (nonatomic, strong, readonly) UIColor *blueBubbleColor, *greyBubbleColor;

@end

@protocol MessageCellDelegate <NSObject>

- (void)performZoomImageView:(UIImageView *)imageView;
- (void)performPlayVideoUID:(NSString *)videoUID forMessageCell:(MessageCell *)messageCell;

@end

NS_ASSUME_NONNULL_END
