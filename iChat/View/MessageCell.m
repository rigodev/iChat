//
//  MessageCell.m
//  iChat
//
//  Created by rigo on 25/03/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "MessageCell.h"

@interface MessageCell()

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIView *bubbleView;

@end

@implementation MessageCell

- (void)setMessageText:(NSString *)text
{
    self.messageTextView.text = [text copy];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _blueBubbleColor = [UIColor colorWithRed:50.0/255.0 green:187.0/255.0 blue:186.0/255.0 alpha:1];
    _greyBubbleColor = [UIColor colorWithRed:59.0/255.0 green:74.0/255.0 blue:104.0/255.0 alpha:1];
    
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.textColor = [UIColor whiteColor];
    self.messageTextView.font = [UIFont systemFontOfSize:16];
    self.bubbleView.backgroundColor = _blueBubbleColor;
    self.bubbleView.layer.cornerRadius = 5;
    self.bubbleView.layer.masksToBounds = true;
    
    self.bubbleView.translatesAutoresizingMaskIntoConstraints = false;
    [self.bubbleView.topAnchor constraintEqualToAnchor:self.topAnchor].active = true;
    [self.bubbleView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = true;
    
    self.messageTextView.translatesAutoresizingMaskIntoConstraints = false;
    [self.messageTextView.leftAnchor constraintEqualToAnchor:self.bubbleView.leftAnchor constant:5].active = true;
    [self.messageTextView.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor].active = true;
    [self.messageTextView.heightAnchor constraintEqualToAnchor:self.bubbleView.heightAnchor].active = true;
    [self.messageTextView.rightAnchor constraintEqualToAnchor:self.bubbleView.rightAnchor].active = true;
    
    self.bubbleLeftAnchor = [self.bubbleView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:5];
    self.bubbleRightAnchor = [self.bubbleView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-8];
    self.bubbleWidthAnchor = [self.bubbleView.widthAnchor constraintEqualToConstant:20];
    self.bubbleWidthAnchor.active = true;
}

- (void)setBubbleBackgroundColor:(UIColor *)color
{
    self.bubbleView.backgroundColor = color;
}

@end
