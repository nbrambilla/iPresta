//
//  ObjectsMenuViewController.m
//  iPresta
//
//  Created by Nacho on 20/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectsMenuViewController.h"
#import "ObjectsListViewController.h"
#import "ConfigurationViewController.h"
#import "User.h"
#import "iPrestaObject.h"
#import "ProgressHUD.h"
#import "iPrestaNSError.h"

@interface ObjectsMenuViewController ()

@end

@implementation ObjectsMenuViewController

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
    [allObjectsQuery whereKey:@"owner" equalTo:[User currentUser]];
    
    bookCount = audioCount = videoCount = othersCount = 0;
    
    [allObjectsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         [ProgressHUD hideHUDForView:self.view animated:YES];
         
         if (error) [error manageErrorTo:self];          // Si hay error al obtener los objetos
         else                                            // Si se obtienen los objetos, se cuentan cuantos hay de cada tipo
         {
             for (iPrestaObject *object in objects)
             {
                 NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:object.type], @"type", nil];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"IncrementObjectTypeObserver" object:options];
                 
                 options = nil;
             }
             objects = nil;
             
             [self setCountLabels];
         }
     }];
}

- (void)setCountLabels
{
    booksLabel.text = [NSString stringWithFormat:@"Libros\r%d", bookCount];
    audioLabel.text = [NSString stringWithFormat:@"Audio\r%d", audioCount];
    videoLabel.text = [NSString stringWithFormat:@"Video\r%d", videoCount];
    othersLabel.text = [NSString stringWithFormat:@"Otros\r%d", othersCount];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToObjectsList:(id)sender
{
    ObjectsListViewController *viewController = [[ObjectsListViewController alloc] initWithNibName:@"ObjectsListViewController" bundle:nil];
    
    UIButton *pressedButton = (UIButton *)sender;
    [iPrestaObject setTypeSelected:pressedButton.tag];
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
    pressedButton = nil;
}

- (IBAction)goToConfiguration:(id)sender
{
    ConfigurationViewController *viewController = [[ConfigurationViewController alloc] initWithNibName:@"ConfigurationViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController = nil;
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

- (void)incrementObjectType:(NSNotification *)notification
{
    NSInteger type = [[notification.object objectForKey:@"type"] integerValue];
    switch (type)
    {
        case BookType:
            bookCount++;
            break;
        case AudioType:
            audioCount++;
            break;
        case VideoType:
            videoCount++;
            break;
        case OtherType:
            othersCount++;
            break;
        default:
            break;
    }
}

- (void)decrementObjectType:(NSNotification *)notification
{
    NSInteger type = [[notification.object objectForKey:@"type"] integerValue];
    switch (type)
    {
        case BookType:
            bookCount--;
            break;
        case AudioType:
            audioCount--;
            break;
        case VideoType:
            videoCount--;
            break;
        case OtherType:
            othersCount--;
            break;
        default:
            break;
    }
}

@end
