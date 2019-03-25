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

@end

@implementation MessageCell

- (void)setMessageText:(NSString *)text
{
    self.messageTextView.text = [text copy];
}

@end
