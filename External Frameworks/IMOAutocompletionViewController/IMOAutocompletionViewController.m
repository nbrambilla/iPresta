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

#define OFFSET 10

@interface IMOAutocompletionViewController ()

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *results;
@property (retain, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *footerActivityIndicator;

- (void)controllerCancelled;
- (CGFloat)screenHeight;

@end

@implementation IMOAutocompletionViewController

@synthesize searchBar = searchBar_;
@synthesize results = results_;
@synthesize tableView = tableView_;
@synthesize dataSource =  dataSource_;
@synthesize delegate = delegate_;
@synthesize activityIndicatorView = activityIndicatorView_;
@synthesize footerActivityIndicator = footerActivityIndicator_;

- (id)init {
    return  self = [self initWithNibName:nil bundle:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [results_ release];
    [tableView_ release];
    [searchBar_ release];
    
    [self setView:nil];
    [super dealloc];
}

- (void)viewDidLoad
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(controllerCancelled)];
    
    loading = NO;
    
    [[self navigationItem] setRightBarButtonItem:cancelButton];
    [cancelButton release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [searchBar_ becomeFirstResponder];
}

#pragma mark -stuff


-(CGFloat)screenHeight {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        CGSize result = [[UIScreen mainScreen] bounds].size;
        return result.height;
    }
    return 0;
}

- (void)controllerCancelled {
    if ([[UIViewController class] respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - TableView delegate and data source -

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Cell size default is 44.0.
//    // This will return a size of 34.0
//    // The custom cell needs to know the - 10.0 difference
//    return 44.0 + IMOCellSizeMagnitude;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if ((scrollView.contentOffset.y + scrollView.frame.size.height) > (scrollView.contentSize.height) && !loading && !finish)
    {
        loading = YES;
        page++;
        [self.footerActivityIndicator startAnimating];
        [self searchResults];
//        [[self footerActivityIndicator] startAnimating];
//        [self performSelector:@selector(stopAnimatingFooter) withObject:nil afterDelay:0.5];
//        return;
	}
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [results_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *completionCell = @"completionCell";
//    
//    IMOCompletionCell *cell = [tableView dequeueReusableCellWithIdentifier:completionCell];
//    if (nil == cell) {
//        if ([self cellColorsArray]) { // call with custom colors
//            cell = [[[IMOCompletionCell alloc] initWithStyle:UITableViewCellStyleValue1
//                                             reuseIdentifier:completionCell
//                                                  cellColors:[self cellColorsArray]]autorelease];
//        }else { // call with default colors
//            cell = [[[IMOCompletionCell alloc]initWithStyle:UITableViewCellStyleValue1
//                                            reuseIdentifier:completionCell] autorelease];
//        }
//    }
    static NSString *CellIdentifier = @"Object";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.tag = indexPath.row;
    iPrestaObject *object = [results_ objectAtIndex:indexPath.row];
    
    cell.textLabel.text = object.name;
    
    if (object.author)
    {
        cell.detailTextLabel.text = [object objectForKey:@"author"];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"camera_icon.png"];
    
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
    if ([[self delegate] respondsToSelector:@selector(IMOAutocompletionViewControllerReturnedCompletion:)]) {
        [[self delegate] IMOAutocompletionViewControllerReturnedCompletion:[results_ objectAtIndex:indexPath.row]];
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Textfield delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    finish = NO;
    page = 0;
    results_ = [[NSMutableArray alloc] init];
    [self searchResults];
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)searchResults
{
    if ([[self dataSource] respondsToSelector:@selector(sourceForAutoCompletionTextField:withParam:page:offset:)])
    {
        
        [(id <IMOAutocompletionViewDataSource>)[self dataSource] sourceForAutoCompletionTextField:self withParam:[searchBar_.text encodeToURL] page:page offset:OFFSET];
    }
    
    [searchBar_ resignFirstResponder];
}

- (void)loadSearchTableWithResults:(NSArray *)searchResults
{
    [ProgressHUD hideHUDForView:self.view animated:YES];

    if (page == 0)
    {
        //set tableview footer
        [[NSBundle mainBundle] loadNibNamed:@"ActivityIndicatorCell" owner:self options:nil];
        [tableView_ setTableFooterView:activityIndicatorView_];
        
        [tableView_ setContentOffset:CGPointZero animated:NO];
    }
    
    
    [self.footerActivityIndicator stopAnimating];
    [results_ addObjectsFromArray:searchResults];
    [[self tableView] reloadData];
    loading = NO;

    
    if ([searchResults count] < OFFSET)
    {
        finish = YES;
        [tableView_ setTableFooterView:nil];
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
}
@end
