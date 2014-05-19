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
#import "ObjectIP.h"
#import "iPrestaNSString.h"
#import "iPrestaNSError.h"
#import "SearchObjectCell.h"

#define OFFSET 10

@interface IMOAutocompletionViewController ()

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *results;
@property (retain, nonatomic) NSMutableArray *owners;
@property (retain, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *footerActivityIndicator;
@property (nonatomic,retain) IBOutlet UILabel *activityIndicatorLabel;

- (void)controllerCancelled;
- (CGFloat)screenHeight;

@end

@implementation IMOAutocompletionViewController

@synthesize searchBar = _searchBar;
@synthesize results = _results;
@synthesize owners = _owners;
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

- (id)initWithCancelButton:(BOOL)setCancelButton andPagination:(BOOL)setPagination nibName:(NSString *)nibNameOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    
	if (self)
    {
        isPaginable = setPagination;
        isCancelButton = setCancelButton;
    }
    
    return self;
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
    [self setOwners:nil];
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
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - TableView delegate and data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isPaginable)
    {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) > (scrollView.contentSize.height) && !loading && !finish)
        {
            _activityIndicatorLabel.text = IPString(@"Cargando...");
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
    SearchObjectCell *cell = (SearchObjectCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchObjectCell" owner:self options:nil] objectAtIndex:0];
        cell.tag = indexPath.row;
    }
    
    ObjectIP *object = [_results objectAtIndex:indexPath.row];
    PFUser *owner = (_owners.count != 0) ? [_owners objectAtIndex:indexPath.row] : nil;
    
    [cell setObject:object withOwner:owner];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(IMOAutocompletionViewControllerReturnedCompletion:)])
    {
        [self.delegate IMOAutocompletionViewControllerReturnedCompletion:[_results objectAtIndex:indexPath.row]];
    }
    
    if (isCancelButton) [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Textfield delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    finish = NO;
    page = 0;
    _results = [NSMutableArray new];
    _owners = [NSMutableArray new];
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

- (void)loadSearchTableWithResults:(NSDictionary *)searchResults error:(NSError *)error
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    loading = NO;
    
    if (error)
    {
        if (page != 0)
        {
            [_footerActivityIndicator stopAnimating];
            _activityIndicatorLabel.text = IPString(@"Intentelo otra vez");
        }
        [error manageError];
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
        
        [_owners addObjectsFromArray:[searchResults objectForKey:@"owners"]];
        [_results addObjectsFromArray:[searchResults objectForKey:@"objects"]];
        [_tableView reloadData];
    
        if ([[searchResults objectForKey:@"objects"] count] < OFFSET)
        {
            finish = YES;
            [_tableView setTableFooterView:nil];
        }
    }
}

@end
