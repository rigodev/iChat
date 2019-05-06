//
//  UserMessageCell.m
//  iChat
//
//  Created by rigo on 04/04/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import "UserMessageCell.h"

@interface UserMessageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTimeLabel;

@end

@implementation UserMessageCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    [self configureCell];
}

- (void)configureCell
{
    self.avatarImageView.layer.cornerRadius = 25.0;
    self.avatarImageView.clipsToBounds = true;
}

- (void)setAvatarImage:(UIImage  * _Nonnull)avatarImage
{
    self.avatarImageView.image = [avatarImage copy];
}

- (void)setTextNameLabel:(NSString  * _Nonnull)text
{
    self.contactNameLabel.text = [text copy];
}

- (void)setTextMessageLabel:(NSString  * _Nonnull)text
{
    self.messageTextLabel.text = [text copy];
}

- (void)setMessageDateTime:(NSNumber  * _Nonnull)dateTime
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    [dateFormatter setLocalizedDateFormatFromTemplate:@"MMMMd"];
    
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"HH:mm";
    
    self.messageDateLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970: dateTime.doubleValue/1000.0]];
    self.messageTimeLabel.text = [timeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970: dateTime.doubleValue/1000.0]];
}

- (void)resetCellConfiguration
{
    self.avatarImageView.image = nil;
    self.messageTextLabel.text = nil;
    self.contactNameLabel.text = nil;
    self.messageDateLabel.text = nil;
    self.messageTimeLabel.text = nil;
}

@end
