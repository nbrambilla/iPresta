//
//  iPrestaImageView.m
//  iPresta
//
//  Created by Nacho Brambilla on 14/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface iPrestaImageView ()

@property(retain, nonatomic) IBOutlet UIButton *deleteButton;
@property(retain, nonatomic) IBOutlet UIImageView *imageView;
@property(readonly, nonatomic) BOOL isSetted;

@end

@implementation iPrestaImageView

@synthesize deleteButton = _deleteButton;
@synthesize imageView = _imageView;
@synthesize isSetted = _isSetted;
@synthesize delegate = _delegate;

- (id) awakeAfterUsingCoder:(NSCoder*)aDecoder
{
    BOOL theThingThatGotLoadedWasJustAPlaceholder = ([self.subviews count] == 0);
    
    if (theThingThatGotLoadedWasJustAPlaceholder)
    {
        // load the embedded view from its Nib
        CGRect frame = self.frame;
        
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([iPrestaImageView class]) owner:nil options:nil] objectAtIndex:0];
        
        self.frame = frame;
        
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([iPrestaImageView class]) owner:nil options:nil] objectAtIndex:0];
        
        self.frame = frame;
        
        [self deleteImage];
        _imageView.layer.borderColor = [[UIColor blackColor] CGColor];
        _imageView.layer.borderWidth = 1.0f;
        [_imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        
        _deleteButton.hidden = YES;
        _isSetted = NO;
    }
    return self;
}
- (IBAction)tapImegeView:(id)sender
{
    if ([_delegate respondsToSelector:@selector(tapImageView)])
    {
        [_delegate tapImageView];
    }
}

- (IBAction)deleteImage:(id)sender
{
    [self deleteImage];
}

- (void)deleteImage
{
    _imageView.image = [UIImage imageNamed:@"camera_icon.png"];
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
}

- (UIImage *)getImage
{
    return _imageView.image;
}

- (void) observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *) change context:(void *)context
{
    // this method is used for all observations, so you need to make sure
    // you are responding to the right one.
    if (object == _imageView && [path isEqualToString:@"image"])
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
    _imageView = pictureView;
}

- (UIImageView *)pictureView
{
    return _imageView;
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
