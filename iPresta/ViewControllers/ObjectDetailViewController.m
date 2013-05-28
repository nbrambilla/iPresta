//
//  ObjectDetailViewController.m
//  iPresta
//
//  Created by Nacho on 14/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectDetailViewController.h"
#import "GiveObjectViewController.h"
#import "iPrestaObject.h"

@interface ObjectDetailViewController ()

@end

@implementation ObjectDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setView) name:@"setObjectViewObserver" object:nil];
    
    [self setView];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)setView
{
    typeLabel.text = [[iPrestaObject currentObject] textType];
    nameLabel.text = [[iPrestaObject currentObject] name];
    authorLabel.text = [[iPrestaObject currentObject] author];
    editorialLabel.text = [[iPrestaObject currentObject] editorial];
    descriptionLabel.text = [[iPrestaObject currentObject] descriptionObject];
    stateLabel.text = [[iPrestaObject currentObject] textState];
    imageView.image = [UIImage imageWithData:[[iPrestaObject currentObject] imageData]];
    if ([[iPrestaObject currentObject] state] == Given)
    {
        giveButton.hidden = YES;
    }
}

- (void)viewDidUnload
{
    typeLabel = nil;
    nameLabel = nil;
    authorLabel = nil;
    editorialLabel = nil;
    stateLabel = nil;
    descriptionLabel = nil;
    giveButton = nil;
    [super viewDidUnload];
}

- (IBAction)goToGiveObject:(id)sender
{
    GiveObjectViewController *viewController = [[GiveObjectViewController alloc] initWithNibName:@"GiveObjectViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];

    viewController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
