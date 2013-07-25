//
//  ObjectsMenuViewController.h
//  iPresta
//
//  Created by Nacho on 20/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOAutocompletionViewController.h"

@interface ObjectsMenuViewController : UIViewController <IMOAutocompletionViewDelegate, IMOAutocompletionViewDataSource>
{
    @private
    IBOutlet UIView *objectsButtonsView;
    IBOutlet UIButton *booksListButton;
    IBOutlet UIButton *audioListButton;
    IBOutlet UIButton *videoListButton;
    IBOutlet UIButton *othersListButton;
    IBOutlet UIButton *configButton;
    IBOutlet UIButton *contactsButton;
    IBOutlet UIButton *searchButton;
    
    IBOutlet UIView *extrasButtonsView;
    IBOutlet UILabel *booksLabel;
    IBOutlet UILabel *audioLabel;
    IBOutlet UILabel *videoLabel;
    IBOutlet UILabel *othersLabel;
    IBOutlet UILabel *configLabel;
    IBOutlet UILabel *contactsLabel;
    IBOutlet UILabel *searchLabel;
    
    NSMutableArray *objectCountArray;
    IMOAutocompletionViewController *autoComplete;
}

@end
