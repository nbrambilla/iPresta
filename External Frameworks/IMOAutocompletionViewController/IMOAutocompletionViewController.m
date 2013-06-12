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

@interface IMOAutocompletionViewController ()

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSArray *results;

- (void)controllerCancelled;
- (CGFloat)screenHeight;

@end

@implementation IMOAutocompletionViewController

@synthesize searchBar = searchBar_;
@synthesize results = results_;
@synthesize tableView = tableView_;
@synthesize dataSource =  dataSource_;
@synthesize delegate = delegate_;

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
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
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
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([[self dataSource] respondsToSelector:@selector(sourceForAutoCompletionTextField:withParam:)]){
        
        NSString *param = [[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        
        param = [param stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSData *paramData = [param dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        param = [[NSString alloc] initWithData:paramData encoding:NSASCIIStringEncoding];
        
        [(id <IMOAutocompletionViewDataSource>)[self dataSource] sourceForAutoCompletionTextField:self withParam:param];
    }
    
    [searchBar_ resignFirstResponder];
}

- (void)loadSearchTableWithResults:(NSArray *)searchResults
{
    [ProgressHUD hideHUDForView:self.view animated:YES];
    
    results_ = [[NSArray alloc] initWithArray:searchResults];;
    [[self tableView] reloadData];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
}
@end
