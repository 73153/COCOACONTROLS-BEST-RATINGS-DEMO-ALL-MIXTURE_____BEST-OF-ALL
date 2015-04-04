//
//  NGColoredViewController.m
//  NGTabBarControllerDemo
//
//  Created by Tretter Matthias on 16.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NGColoredViewController.h"
#import "NGTabBarController.h"
#import <QuartzCore/QuartzCore.h>


#define NGLogFunction() NSLog(@"Method called: %s", __FUNCTION__)


@interface NGColoredViewController () {
    BOOL _presentedModally;
}

@end

@implementation NGColoredViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *randomColor = [UIColor colorWithRed:arc4random()%256/255. green:arc4random()%256/255. blue:arc4random()%256/255. alpha:1.f];
    
    self.view.backgroundColor = randomColor;
    self.view.layer.borderColor = [UIColor orangeColor].CGColor;
    self.view.layer.borderWidth = 2.f;
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    blackView.backgroundColor = [UIColor blackColor];
    blackView.center = self.view.center;
    blackView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:blackView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Push Me" forState:UIControlStateNormal];
    button.frame = CGRectMake(self.view.bounds.size.width - 120, 20, 100, 100);
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button addTarget:self action:@selector(handleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    NGLogFunction();
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    NGLogFunction();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NGLogFunction();
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NGLogFunction();
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    NGLogFunction();
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    
    NGLogFunction();
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NGLogFunction();
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NGLogFunction();
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    NGLogFunction();
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)handleButtonPress:(id)sender {
    if (_presentedModally) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        NGColoredViewController *vc = [[NGColoredViewController alloc] initWithNibName:nil bundle:nil];
        
        vc->_presentedModally = YES;
        [self.ng_tabBarController presentModalViewController:vc animated:YES];
    }
}

@end
