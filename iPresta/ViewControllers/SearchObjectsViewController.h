//
//  SearchObjectsViewController.h
//  iPresta
//
//  Created by Nacho on 15/08/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"
#import "ObjectIP.h"

@interface SearchObjectsViewController : SlideViewController <ObjectIPDelegate, IMOAutocompletionViewDataSource, IMOAutocompletionViewDelegate>
{
    @private
    NSMutableArray *objects;
    NSMutableArray *owners;
}

@end