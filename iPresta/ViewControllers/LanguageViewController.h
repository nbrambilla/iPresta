//
//  LanguageViewController.h
//  iPresta
//
//  Created by Nacho on 17/10/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LanguageViewController : UIViewController <UITabBarControllerDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableLanguages;
}

@end
