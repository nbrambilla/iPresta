//
//  ObjectDetailViewController.h
//  iPresta
//
//  Created by Nacho on 14/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPrestaObject.h"

@interface ObjectDetailViewController : UIViewController
{
    @private
    iPrestaObject *object;
    IBOutlet UILabel *typeLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *authorLabel;
    IBOutlet UILabel *editorialLabel;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UILabel *stateLabel;
}

@property(strong, nonatomic) iPrestaObject *object;

@end
