//
//  ObjectsMenuViewController.h
//  iPresta
//
//  Created by Nacho on 20/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjectsMenuViewController : UIViewController
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
    
    NSInteger bookCount;
    NSInteger audioCount;
    NSInteger videoCount;
    NSInteger othersCount;
}

@end
