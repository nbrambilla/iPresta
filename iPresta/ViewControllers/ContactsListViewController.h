//
//  ContactsListViewController.h
//  iPresta
//
//  Created by Nacho Brambilla  on 21/05/14.
//  Copyright (c) 2014 Nacho. All rights reserved.
//

#import "SlideViewController.h"
#import "UserIP.h"

@interface ContactsListViewController : SlideViewController <UserIPDelegate>
{
    NSMutableArray *appContactsList;
    NSMutableArray *filteredAppContactsList;
}

@end
