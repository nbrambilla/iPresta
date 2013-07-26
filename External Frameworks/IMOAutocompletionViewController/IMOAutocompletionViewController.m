//
//  IMOAutocompletionViewController.m
//  IMOAutoCompletionTextField DEMO
//
//  Created by Cormier Frederic on 28/05/12.
//  Copyright (c) 2012 International MicrOondes. All rights reserved.
//

#import "IMOAutocompletionViewController.h"
#import "IMOCompletionCell.h"
#import "IMOCompletionController.h"
#import "ProgressHUD.h"
#import "iPrestaObject.h"
#import "iPrestaNSString.h"
#import "iPrestaNSError.h"

#define OFFSET 10

@interface IMOAutocompletionViewController ()

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *results;
@property (retain, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *footerActivityIndicator;
@property (nonatomic,retain) IBOutlet UILabel *activityIndicatorLabel;

- (void)controllerCancelled;
- (CGFloat)screenHeight;

@end

@implementation IMOAutocompletionViewController

@synthesize searchBar = _searchBar;
@synthesize results = _results;
@synthesize tableView = _tableView;
@synthesize dataSource =  _dataSource;
@synthesize delegate = _delegate;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize footerActivityIndicator = _footerActivityIndicator;
@synthesize activityIndicatorLabel = _activityIndicatorLabel;

- (id)init
{
    return  self = [self initWithNibName:nil bundle:nil];
}

- (id)initWithCancelButton:(BOOL)setCancelButton andPagination:(BOOL)setPagination
{
    self = [super init];
    
	if (self)
    {
        isPaginable = setPagination;
        isCancelButton = setCancelButton;
    }
    
    return self;
}

- (void)viewDidUnload
{
    [self setResults:nil];
    [self setTableView:nil];
    [self setSearchBar:nil];
    [self setDataSource:nil];
    [self setDelegate:nil];
    [self setActivityIndicatorView:nil];
    [self setFooterActivityIndicator:nil];
    [self setActivityIndicatorView:nil];
    
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (isCancelButton) [self setCancelButton];
    [_searchBar becomeFirstResponder];
    loading = NO;
}

#pragma mark -stuff

- (void)setCancelButton
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(controllerCancelled)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    cancelButton = nil;
}

- (CGFloat)screenHeight
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        return result.height;
    }
    return 0;
}

- (void)controllerCancelled
{
    if ([[UIViewController class] respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - TableView delegate and data source

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isPaginable)
    {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) > (scrollView.contentSize.height) && !loading && !finish)
        {
            _activityIndicatorLabel.text = @"Cargando...";
            loading = YES;
            page++;
            [self.footerActivityIndicator startAnimating];
            [self searchResults];
        }
    }
    else
    {
        [_tableView setTableFooterView:nil];
        //_tableView.delegate = nil;
    }
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Object";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.tag = indexPath.row;
    iPrestaObject *object = [_results objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [object.name capitalizedString];
    
    if (object.author)
    {
        cell.detailTextLabel.text = [[object objectForKey:@"author"] capitalizedString];
    }
    
    cell.imageView.image = [UIImage imageNamed:[iPrestaObject imageType:object.type]];
    
    if (!object.imageData)
    {
        [object.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 object.imageData = [[NSData alloc] initWithData:data];
                 UIImage* image = [UIImage imageWithData:data];
                 if (image)
                 {
                     dispatch_async(dispatch_get_main_queue(),
                        ^{
                            if (cell.tag == indexPath.row)
                            {
                                cell.imageView.image = image;
                                [cell setNeedsLayout];
                            }
                        });
                 }
             }
         }];
    }
    
    if (object.imageData)
    {
        cell.imageView.image = [UIImage imageWithData:object.imageData];
    }
    
    else if (object.imageURL && object.imageData == nil)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        dispatch_async(queue, ^(void)
        {
            object.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:object.imageURL]];
                                 
            UIImage* image = [UIImage imageWithData:object.imageData];
            if (image)
            {
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    if (cell.tag == indexPath.row)
                    {
                        cell.imageView.image = image;
                        [cell setNeedsLayout];
                    }
                });
            }
        });
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(IMOAutocompletionViewControllerReturnedCompletion:)])
    {
        [self.delegate IMOAutocompletionViewControllerReturnedCompletion:[_results objectAtIndex:indexPath.row]];
    }
    
    if (isCancelButton) [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Textfield delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    finish = NO;
    page = 0;
    _results = [[NSMutableArray alloc] init];
    [self searchResults];
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)searchResults
{
    if (isPaginable)
    {
        if ([[self dataSource] respondsToSelector:@selector(sourceForAutoCompletionTextField:withParam:page:offset:)])
        {
            [(id <IMOAutocompletionViewDataSource>)[self dataSource] sourceForAutoCompletionTextField:self withParam:[_searchBar.text encodeToURL] page:page offset:OFFSET];
        }
    }
    else
    {
        if ([[self dataSource] respondsToSelector:@selector(sourceForAutoCompletionTextField:withParam:)])
        {
            [(id <IMOAutocompletionViewDataSource>)[self dataSource] sourceForAutoCompletionTextField:self withParam:[_searchBar.text encodeToURL]];
        }
    }

    [_searchBar resignFirstResponder];
}

- (void)loadSearchTableWithResults:(NSArray *)searchResults error:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    loading = NO;
    
    if (error)
    {
        if (page != 0)
        {
            [_footerActivityIndicator stopAnimating];
            _activityIndicatorLabel.text = @"Intentelo otra vez";
        }
        [error manageErrorTo:self.view];
    }
    else
    {
        if (page == 0)
        {
            //set tableview footer
            [[NSBundle mainBundle] loadNibNamed:@"ActivityIndicatorCell" owner:self options:nil];
            [_tableView setTableFooterView:_activityIndicatorView];
            
            [_tableView setContentOffset:CGPointZero animated:NO];
        }
        
        [_results addObjectsFromArray:searchResults];
        [_tableView reloadData];
    
        if ([searchResults count] < OFFSET)
        {
            finish = YES;
            [_tableView setTableFooterView:nil];
        }
    }
}

@end
