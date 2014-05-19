//
//  ObjectHistoricGiveViewController.h
//  iPresta
//
//  Created by Nacho on 03/06/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjectHistoricGiveViewController : UIViewController
{
    @private
    NSArray *givesArray;
    
    IBOutlet UITableView *tableView;
    IBOutlet UIView *noLoansView;
    IBOutlet UILabel *noLoansLabel;
}

@end
