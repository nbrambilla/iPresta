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

@optional
- (void)sourceForAutoCompletionTextField:(IMOAutocompletionViewController *)asViewController withParam:(NSString *)param page:(NSInteger)_page offset:(NSInteger)offset;
- (void)sourceForAutoCompletionTextField:(IMOAutocompletionViewController *)asViewController withParam:(NSString *)param;

@end


@protocol IMOAutocompletionViewDelegate <NSObject>

- (void)IMOAutocompletionViewControllerReturnedCompletion:(NSString *)completion;

@end

@interface IMOAutocompletionViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSInteger page;
    BOOL loading;
    BOOL finish;
    BOOL isPaginable;
    BOOL isCancelButton;
}

@property (assign, nonatomic) id <IMOAutocompletionViewDataSource> dataSource;
@property (assign, nonatomic) id <IMOAutocompletionViewDelegate> delegate;

- (id)initWithCancelButton:(BOOL)setCancelButton andPagination:(BOOL)setPagination;
- (void)loadSearchTableWithResults:(NSDictionary *)searchResults error:(NSError *)error;
- (id)initWithCancelButton:(BOOL)setCancelButton andPagination:(BOOL)setPagination nibName:(NSString *)nibNameOrNil;

@end

