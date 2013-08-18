//
//  ObjectsMenuViewController.h
//  iPresta
//
//  Created by Nacho on 20/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"

@interface ObjectsMenuViewController : SlideViewController
{
    @private
    IBOutlet UIButton *booksListButton;
    IBOutlet UIButton *audioListButton;
    IBOutlet UIButton *videoListButton;
    IBOutlet UIButton *othersListButton;
    
    IBOutlet UILabel *booksLabel;
    IBOutlet UILabel *audioLabel;
    IBOutlet UILabel *videoLabel;
    IBOutlet UILabel *othersLabel;

    
    NSMutableArray *objectCountArray;
}

@end
