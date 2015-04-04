//
//  ViewController.m
//  MultiContactsSelector
//
//  Created by Sergio on 25/10/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Addressbook Utilities
    //NSLog(@"%@", [NSObject getAllRecordIDs]);
    //NSLog(@"%@", [NSObject infoWithRecordID:1]);
    
    UIButton *showContacts = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    showContacts.frame = CGRectMake(80, 100, 150, 50);
    [showContacts addTarget:self action:@selector(showContacts) forControlEvents:UIControlEventTouchUpInside];
    showContacts.titleLabel.textColor = [UIColor blackColor];
    showContacts.titleLabel.text = @"Show contacts";
    [self.view addSubview:showContacts];
}

- (void)showContacts
{
    SMContactsSelector *controller = [[SMContactsSelector alloc] initWithNibName:@"SMContactsSelector" bundle:nil];
    controller.delegate = self;
    controller.requestData = DATA_CONTACT_TELEPHONE; // DATA_CONTACT_ID DATA_CONTACT_EMAIL , DATA_CONTACT_TELEPHONE
    controller.showModal = YES; //Mandatory: YES or NO
    controller.showCheckButton = YES; //Mandatory: YES or NO
    
    // Set your contact list setting record ids (optional)
    //controller.recordIDs = [NSArray arrayWithObjects:@"1", @"2", nil];
    
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

#pragma -
#pragma SMContactsSelectorDelegate Methods

- (void)numberOfRowsSelected:(NSInteger)numberRows withData:(NSArray *)data andDataType:(DATA_CONTACT)type
{
    if (type == DATA_CONTACT_TELEPHONE)
    {
        for (int i = 0; i < [data count]; i++)
        {
            NSString *str = [data objectAtIndex:i];
            
            str = [str reformatTelephone];
            
            NSLog(@"Telephone: %@", str);		
        }
    }
    else if (type == DATA_CONTACT_EMAIL)
    {
        for (int i = 0; i < [data count]; i++)
        {
            NSString *str = [data objectAtIndex:i];
            
            NSLog(@"Emails: %@", str);		
        }
    }
	else
    {
        for (int i = 0; i < [data count]; i++)
        {
            NSString *str = [data objectAtIndex:i];
            
            NSLog(@"IDs: %@", str);		
        } 
    }
}

@end
