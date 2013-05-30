//
//  ObjectDetailViewController.h
//  iPresta
//
//  Created by Nacho on 14/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ObjectDetailViewController : UIViewController
{
    @private
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *typeLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *authorLabel;
    IBOutlet UILabel *editorialLabel;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UILabel *stateLabel;
    IBOutlet UIButton *giveButton;
    IBOutlet UIButton *giveBackButton;
}

@end
