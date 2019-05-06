//
//  MessageCell.m
//  iChat
//
//  Created by rigo on 25/03/2019.
//  Copyright © 2019 dev. All rights reserved.
//

#import "MessageCell.h"

@interface MessageCell()

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

@end

@implementation MessageCell
{
    AVPlayerLayer *_playerLayer;
}

- (void)setMessageText:(NSString *)text
{
    self.messageTextView.text = [text copy];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _blueBubbleColor = [UIColor colorWithRed:50.0/255.0 green:187.0/255.0 blue:186.0/255.0 alpha:1];
    _greyBubbleColor = [UIColor colorWithRed:59.0/255.0 green:74.0/255.0 blue:104.0/255.0 alpha:1];
    
    self.bubbleView.backgroundColor = _blueBubbleColor;
    self.bubbleView.layer.cornerRadius = 5;
    self.bubbleView.layer.masksToBounds = true;
    self.messageImageView.layer.cornerRadius = 5;
    self.messageImageView.layer.masksToBounds = true;
    
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
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewTapRecognizer:)];
    [self.messageImageView addGestureRecognizer:tapRecognizer];
}

- (IBAction)handlePlayButtonTap:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(performPlayVideoUID:forMessageCell:)])
    {
        [self.loadingSpinner startAnimating];
        self.playButton.hidden = true;
        
        [self.delegate performPlayVideoUID:self.videoUID forMessageCell:self];
    }
}

- (void)setupPlayerLayer:(AVPlayerLayer *)playerLayer;
{
    _playerLayer = playerLayer;
    _playerLayer.frame = self.bubbleView.bounds;
    [self.bubbleView.layer addSublayer:_playerLayer];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.videoUID = nil;
    
    if(_playerLayer)
    {
        [_playerLayer removeFromSuperlayer];
        [_playerLayer.player pause];
    }
    
    [self.loadingSpinner stopAnimating];
}

- (void)handleImageViewTapRecognizer:(UITapGestureRecognizer *)tapRecognizer
{
    if(self.videoUID || [self.videoUID isEqualToString:@""])
    {
        return;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(performZoomImageView:)])
    {
        [self.delegate performZoomImageView:self.messageImageView];
    }
}

- (void)setBubbleBackgroundColor:(UIColor *)color
{
    self.bubbleView.backgroundColor = color;
}

- (void)setHiddenImageView:(BOOL)hidden
{
    self.messageImageView.hidden = hidden;
}

- (void)setHiddenTextView:(BOOL)hidden
{
    self.messageTextView.hidden = hidden;
}

- (void)setImageForMessageImageView:(UIImage *)image
{
    self.messageImageView.image = image;
}

- (void)setHiddenPlayButton:(BOOL)hidden
{
    self.playButton.hidden = hidden;
}

@end
