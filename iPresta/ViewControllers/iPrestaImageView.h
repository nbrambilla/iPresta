//
//  iPrestaImageView.h
//  iPresta
//
//  Created by Nacho Brambilla on 14/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol iPrestaImageViewDelegate <NSObject>

@optional
- (void)tapImageView;

@end

@interface iPrestaImageView : UIView
{
    @private
    IBOutlet id<iPrestaImageViewDelegate> delegate;
}

@property(retain, nonatomic) IBOutlet id<iPrestaImageViewDelegate> delegate;

- (void)deleteImage;
- (BOOL)isSetted;
- (void)setImageWithURL:(NSString *)url;
- (void)setImage:(UIImage *)image;
- (UIImage *)getImage;

@end
