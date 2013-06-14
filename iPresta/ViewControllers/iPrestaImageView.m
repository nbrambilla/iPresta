//
//  iPrestaImageView.m
//  iPresta
//
//  Created by Nacho Brambilla on 14/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation iPrestaImageView

@synthesize pictureView = _pictureView;
@synthesize isSetted = _isSetted;

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"iPrestaImageView" owner:nil options:nil] objectAtIndex:0];
    if (self) {
        [self deleteImage];
        _pictureView.layer.borderColor = [[UIColor blackColor] CGColor];
        _pictureView.layer.borderWidth = 1.0f;
        
        _deleteButton.hidden = YES;
        _isSetted = NO;
        
        [_pictureView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}

- (IBAction)deleteImage:(id)sender
{
    [self deleteImage];
}

- (void)deleteImage
{
    _pictureView.image = [UIImage imageNamed:@"camera_icon.png"];
}

- (void)setImage:(UIImage *)image
{
    _pictureView.image = image;
}

- (UIImage *)getImage
{
    return _pictureView.image;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *) change context:(void *)context
{
    // this method is used for all observations, so you need to make sure
    // you are responding to the right one.
    if (object == _pictureView && [path isEqualToString:@"image"])
    {
        UIImage *newImage = [change objectForKey:NSKeyValueChangeNewKey];
//        UIImage *oldImage = [change objectForKey:NSKeyValueChangeOldKey];
        
        if (newImage == [UIImage imageNamed:@"camera_icon.png"])
        {
            _deleteButton.hidden = YES;
            _isSetted = NO;
        }
        else
        {
            _deleteButton.hidden = NO;
            _isSetted = YES;
        }
        
        // oldImage is the image *before* the property changed
        // newImage is the image *after* the property changed
    }
}

- (void)setPictureView:(UIImageView *)pictureView
{
    _pictureView = pictureView;
}

- (UIImageView *)pictureView
{
    return _pictureView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
