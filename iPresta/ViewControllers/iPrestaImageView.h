//
//  iPrestaImageView.h
//  iPresta
//
//  Created by Nacho Brambilla on 14/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPrestaImageView : UIView

@property(strong, nonatomic) IBOutlet UIImageView *pictureView;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property(readonly, nonatomic) BOOL *isSetted;

- (void)deleteImage;

@end
