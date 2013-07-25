//
//  IMOAutocompletionViewController.h
//  IMOAutoCompletionTextField DEMO
//
//  Created by Cormier Frederic on 28/05/12.
//  Copyright (c) 2012 International MicrOondes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMOAutocompletionViewController;


@protocol IMOAutocompletionViewDataSource <NSObject>

- (void)sourceForAutoCompletionTextField:(IMOAutocompletionViewController *)asViewController withParam:(NSString *)param page:(NSInteger)page offset:(NSInteger)offset;

@end


@protocol IMOAutocompletionViewDelegate <NSObject>

- (void)IMOAutocompletionViewControllerReturnedCompletion:(NSString *)completion;

@end

@interface IMOAutocompletionViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSInteger page;
    BOOL loading;
    BOOL finish;
}

@property (assign, nonatomic) id <IMOAutocompletionViewDataSource> dataSource;
@property (assign, nonatomic) id <IMOAutocompletionViewDelegate> delegate;

- (id)initWithCancelButton:(BOOL)setCancelButton;
- (void)loadSearchTableWithResults:(NSArray *)searchResults error:(NSError *)error;

@end

