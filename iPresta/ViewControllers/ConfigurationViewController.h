//
//  ConfigurationViewController.h
//  iPresta
//
//  Created by Nacho on 19/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"

@interface ConfigurationViewController : SlideViewController
{
    @private
    IBOutlet UISwitch *visibleSwitch;
}

@end
