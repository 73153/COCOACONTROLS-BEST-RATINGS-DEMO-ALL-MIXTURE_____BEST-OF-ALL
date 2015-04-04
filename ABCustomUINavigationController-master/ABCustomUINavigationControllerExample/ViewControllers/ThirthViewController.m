//
//  ThirthViewController.m
//  SquaresFlipNavigationExample
//
//  Created by Andrés Brun on 7/25/13.
//  Copyright (c) 2013 Andrés Brun. All rights reserved.
//

#import "ThirthViewController.h"
#import "ViewController.h"

@interface ThirthViewController ()

@end

@implementation ThirthViewController

- (id)initViewController
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self = [[ThirthViewController alloc] initWithNibName:@"ThirthViewController_iPhone" bundle:nil];
    } else {
        self = [[ThirthViewController alloc] initWithNibName:@"ThirthViewController_iPad" bundle:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (IBAction)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)popToFirstViewController:(id)sender
{
    ViewController *firstVC = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popToViewController:firstVC animated:YES];
}

- (IBAction)popToRootViewController:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
