//
//  ObjectsMenuViewController.m
//  iPresta
//
//  Created by Nacho on 20/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectsMenuViewController.h"
#import "User.h"
#import "iPrestaObject.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"
#import "ObjectsListViewController.h"

@interface ObjectsMenuViewController ()

@end

@implementation ObjectsMenuViewController

#pragma mark - Lifecycle Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setView];
    [self countObjects];
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) [User setObjectsUser:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:@"IncrementObjectTypeObserver"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"DecrementObjectTypeObserver"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"SetCountLabelsObserver"];
    
    booksListButton = nil;
    audioListButton = nil;
    videoListButton = nil;
    othersListButton = nil;
    
    booksLabel = nil;
    audioLabel = nil;
    videoLabel = nil;
    othersLabel = nil;
    
    [super viewDidUnload];
}

#pragma mark - Buttons Methods

- (IBAction)goToObjectsList:(UIButton *)sender
{
    ObjectsListViewController *viewController = [[ObjectsListViewController alloc] initWithNibName:@"ObjectsListViewController" bundle:nil];
    
    [iPrestaObject setTypeSelected:sender.tag];
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
}

#pragma mark - Private Methods

- (void)setView
{
    self.title = @"Menú";
    
    booksListButton.tag = BookType;
    audioListButton.tag = AudioType;
    videoListButton.tag = VideoType;
    othersListButton.tag = OtherType;
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementObjectType:) name:@"IncrementObjectTypeObserver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementObjectType:) name:@"DecrementObjectTypeObserver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCountLabels) name:@"SetCountLabelsObserver" object:nil];
}

- (void)countObjects
{
    [ProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *allObjectsQuery = [iPrestaObject query];
    [allObjectsQuery whereKey:@"owner" equalTo:[User objectsUser]];
    allObjectsQuery.limit = 1000;
    
    if ([User objectsUserIsSet])
    {
        [allObjectsQuery whereKey:@"visible" equalTo:[NSNumber numberWithBool:YES]];
    }
    
    NSNumber *zero = [NSNumber numberWithInteger:0];
    objectCountArray = [[NSMutableArray alloc] initWithObjects:zero, zero, zero, zero, nil];
    
    [allObjectsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         [ProgressHUD hideHUDForView:self.view animated:YES];
         
         if (error)      // Si hay error al obtener los objetos
         {
             [error manageErrorTo:self];
         }
         else            // Si se obtienen los objetos, se cuentan cuantos hay de cada tipo
         {
             for (iPrestaObject *object in objects)
             {
                 NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:object.type], @"type", nil];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"IncrementObjectTypeObserver" object:options];
                 
                 options = nil;
             }
             
             [self setCountLabels];
         }
     }];
    
    zero = nil;
}

- (void)setCountLabels
{
    booksLabel.text = [NSString stringWithFormat:@"%@", [objectCountArray objectAtIndex:0]];
    audioLabel.text = [NSString stringWithFormat:@"%@", [objectCountArray objectAtIndex:1]];
    videoLabel.text = [NSString stringWithFormat:@"%@", [objectCountArray objectAtIndex:2]];
    othersLabel.text = [NSString stringWithFormat:@"%@", [objectCountArray objectAtIndex:3]];
}

- (void)incrementObjectType:(NSNotification *)notification
{
    NSInteger type = [[notification.object objectForKey:@"type"] integerValue];
    NSInteger count = [[objectCountArray objectAtIndex:type] integerValue] + 1;
    
    [objectCountArray replaceObjectAtIndex:type withObject:[NSNumber numberWithInteger:count]];
}

- (void)decrementObjectType:(NSNotification *)notification
{
    NSInteger type = [[notification.object objectForKey:@"type"] integerValue];
    NSInteger count = [[objectCountArray objectAtIndex:type] integerValue] - 1;
    
    [objectCountArray replaceObjectAtIndex:type withObject:[NSNumber numberWithInteger:count]];
}


@end
