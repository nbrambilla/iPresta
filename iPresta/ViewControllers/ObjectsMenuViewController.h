//
//  ObjectsMenuViewController.h
//  iPresta
//
//  Created by Nacho on 20/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ObjectsMenuViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate>
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
