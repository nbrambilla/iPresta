//
//  iPrestaImageView.h
//  iPresta
//
//  Created by Nacho Brambilla on 14/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPrestaImageView : UIView
{
    @private
    IBOutlet UIButton *_deleteButton;
}

@property(readonly, nonatomic) IBOutlet UIImageView *pictureView;
@property(readonly, nonatomic) BOOL *isSetted;

- (void)deleteImage;
- (void)setImage:(UIImage *)image;
- (UIImage *)getImage;

@end
