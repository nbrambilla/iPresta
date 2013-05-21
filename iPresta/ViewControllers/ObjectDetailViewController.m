//
//  ObjectDetailViewController.m
//  iPresta
//
//  Created by Nacho on 14/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "ObjectDetailViewController.h"

@interface ObjectDetailViewController ()

@end

@implementation ObjectDetailViewController

@synthesize object;

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
    if (object) {
        typeLabel.text = object.textType;
        nameLabel.text = object.name;
        authorLabel.text = object.author;
        editorialLabel.text = object.editorial;
        descriptionLabel.text = object.descriptionObject;
        stateLabel.text = object.textState;
        imageView.image = [UIImage imageWithData:object.imageData];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    object = nil;
    typeLabel = nil;
    nameLabel = nil;
    authorLabel = nil;
    editorialLabel = nil;
    stateLabel = nil;
    descriptionLabel = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
