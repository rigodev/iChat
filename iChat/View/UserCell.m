//
//  UserCell.m
//  iChat
//
//  Created by rigo on 21/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import "UserCell.h"

@interface UserCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation UserCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    [self configureCell];
}

- (void)configureCell
{
    self.avatarImageView.layer.cornerRadius = 25;
    self.avatarImageView.layer.masksToBounds = true;
}

- (void)configureCellWithAvatarImage:(UIImage *)image
{
    self.avatarImageView.image = image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNameText:(NSString *)name
{
    self.nameLabel.text = [name copy];
}

- (void)setAvatarImage:(UIImage *)image
{
    self.avatarImageView.image = image;
}

@end
