//
//  ThirdViewController.m
//  AKTabBar Example
//
//  Created by Ali KARAGOZ on 04/05/12.
//  Copyright (c) 2012 Ali Karagoz. All rights reserved.
//

#import "ThirdViewController.h"

#import "AKTabBarController.h"

@implementation ThirdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Map";
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.akTabBarController setBadgeValue:@"1"
                            forItemAtIndex:2];
}

- (NSString *)tabImageName
{
	return @"image-3";
}

- (NSString *)tabBackgroundImageName {
    return @"noise-dark-green.png";
}

@end
