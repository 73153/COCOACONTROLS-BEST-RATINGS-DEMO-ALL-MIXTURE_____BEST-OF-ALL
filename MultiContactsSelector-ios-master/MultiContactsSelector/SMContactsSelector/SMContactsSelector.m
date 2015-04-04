//
//  SMContactsSelector.m
//  
//
//  Created by Sergio on 03/03/11.
//  Copyright 2011 Sergio. All rights reserved.
//

#import "SMContactsSelector.h"
#import "CustomIOS7AlertView.h"

#define kIOS7TableView 9999

@interface NSString (character)

- (BOOL)isLetterInAlphabet:(NSArray*)alphabet;

- (BOOL)isRecordInArray:(NSArray *)array;

@end

@implementation NSString (character)

- (BOOL)isLetterInAlphabet:(NSArray *)alphabet
{
	BOOL isLetter = NO;
    NSString* firstCharacter = [[self substringToIndex:1] uppercaseString];
	
	for (NSString* letter in alphabet)
	{
		if ([firstCharacter isEqualToString:letter])
		{
			isLetter = YES;
			break;
		}
	}
	
	return isLetter;
}

- (BOOL)isRecordInArray:(NSArray *)array
{
    for (NSString *str in array)
    {
        if ([self isEqualToString:str]) 
        {
            return YES;
        }
    }
    
    return NO;
}

@end

@interface SMContactsSelector ()

- (UIView *)createTableView;

- (void)postActionSelectRowAtIndex:(NSInteger)row
                           section:(NSInteger)section
                       withContext:(id)context
                              text:(NSString *)text
                           andItem:(NSMutableDictionary *)item
                               row:(int)rowSelected;

@property (nonatomic, strong) NSArray *objectsArray;
@property (nonatomic, strong) NSArray *labelsArray;
@property (nonatomic, strong)CustomIOS7AlertView *alertIOS7;
@property (nonatomic, strong)UITableView *telsTable;

@end

@implementation SMContactsSelector
{
    int contactRow;
}

@synthesize telsTable;
@synthesize alertIOS7;
@synthesize objectsArray;
@synthesize labelsArray;
@synthesize table;
@synthesize cancelItem;
@synthesize doneItem;
@synthesize delegate;
@synthesize filteredListContent;
@synthesize savedSearchTerm;
@synthesize savedScopeButtonIndex;
@synthesize searchWasActive;
@synthesize barSearch;
@synthesize alertTable;
@synthesize selectedItem;
@synthesize currentTable;
@synthesize arrayLetters;
@synthesize requestData;
@synthesize alertTitle;
@synthesize recordIDs;
@synthesize showModal;
@synthesize toolBar;
@synthesize showCheckButton;
@synthesize upperBar;

- (id)init
{
    return [self initWithNibName:@"SMContactsSelector" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Default bar style is black, but you can override it to customise the appearance
        self.barStyle = UIBarStyleBlackOpaque;
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    if ((requestData != DATA_CONTACT_TELEPHONE) && 
        (requestData != DATA_CONTACT_EMAIL) &&
        (requestData != DATA_CONTACT_ID))
    {
        [self.navigationController dismissModalViewControllerAnimated:YES];
        
        @throw ([NSException exceptionWithName:@"Undefined data request"
                                        reason:@"Define requestData variable (EMAIL or TELEPHONE)" 
                                      userInfo:nil]);
    }

    self.arrayLetters = [NSLocalizedStringFromTable(@"alphabet", @"SMContactsSelector", nil) componentsSeparatedByString:@" "];
    cancelItem.title = NSLocalizedStringFromTable(@"cancel", @"SMContactsSelector", nil);
    doneItem.title = NSLocalizedStringFromTable(@"done", @"SMContactsSelector", nil);
    alertTitle = NSLocalizedStringFromTable(@"alert_title", @"SMContactsSelector", nil);
    
	cancelItem.action = @selector(dismiss);
	doneItem.action = @selector(acceptAction);
	
    if (!showModal) 
    {
        toolBar.hidden = YES;
        CGRect rect = table.frame;
        rect.size.height += toolBar.frame.size.height;
        table.frame = rect;
        table.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    
    __block SMContactsSelector *controller = self;
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBookRef,
                                                 ^(bool granted, CFErrorRef error) {
                                                     if (granted)
                                                         [controller loadContacts];
                                                     
                                                 });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        // The user has previously given access, add the contact
        [self loadContacts];
        CFRelease(addressBookRef);
    }
    else
    {
        NSString *msg = NSLocalizedStringFromTable(@"permission_denied", @"SMContactsSelector", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        alert.tag = 457;
        [alert show];
        [alert release];
        CFRelease(addressBookRef);
        return;
    }
    
#else
    [self loadContacts];
#endif
    
    selectedRow = [NSMutableArray new];
	table.editing = NO;
    table.backgroundColor = [UIColor clearColor];

    self.upperBar.topItem.title = self.title;
    
    // Set bar style
    self.barSearch.barStyle = self.barStyle;
    self.upperBar.barStyle = self.barStyle;
}

- (void)loadContacts
{
    NSString *objsAux = @"";
    ABAddressBookRef addressBook = ABAddressBookCreate( );
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableSet* allContacts = [[NSMutableSet alloc] initWithCapacity:nPeople];
    
    for (int i = 0; i < nPeople; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        ABMultiValueRef property = ABRecordCopyValue(person, (requestData == DATA_CONTACT_TELEPHONE) ? kABPersonPhoneProperty : kABPersonEmailProperty);
        
        NSArray *propertyArray = (NSArray *)ABMultiValueCopyArrayOfAllValues(property);
        CFRelease(property);
        
        NSString *objs = @"";
        
        BOOL lotsItems = NO;
        for (int i = 0; i < [propertyArray count]; i++)
        {
            if ([objs isEqual: @""])
            {
                objs = [propertyArray objectAtIndex:i];
                objsAux = [objsAux stringByAppendingFormat:@",%@", objs];
            }
            else
            {
                lotsItems = YES;
                objs = [objs stringByAppendingString:[NSString stringWithFormat:@",%@", [propertyArray objectAtIndex:i]]];
                objsAux = [objsAux stringByAppendingFormat:@",%@", objs];
            }
        }
        
        [propertyArray release];
        
        CFStringRef name;
        name = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFStringRef lastNameString;
        lastNameString = ABRecordCopyValue(person, kABPersonLastNameProperty);
     
        NSString *nameString = (NSString *)name;
        
        NSString *lastName = (NSString *)lastNameString;
        int currentID = (int)ABRecordGetRecordID(person);
        
        if ((id)lastNameString != nil)
        {
            nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastName];
        }
        
        NSMutableDictionary *info = [NSMutableDictionary new];
        [info setValue:[NSString stringWithFormat:@"%@", [[nameString stringByReplacingOccurrencesOfString:@" " withString:@""] substringToIndex:1]] forKey:@"letter"];
        [info setValue:[NSString stringWithFormat:@"%@", nameString] forKey:@"name"];
        [info setValue:@"-1" forKey:@"rowSelected"];
        
        if ((![objs isEqual: @""]) || ([[objs lowercaseString] rangeOfString:@"null"].location == NSNotFound))
        {
            if (requestData == DATA_CONTACT_EMAIL)
            {
                [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"email"];
                
                if (!lotsItems)
                {
                    [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"emailSelected"];
                }
                else
                {
                    [info setValue:@"" forKey:@"emailSelected"];
                }
            }
            
            if (requestData == DATA_CONTACT_TELEPHONE)
            {
                [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"telephone"];
                
                if (!lotsItems)
                {
                    [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"telephoneSelected"];
                }
                else
                {
                    [info setValue:@"" forKey:@"telephoneSelected"];
                }
            }
            
            if (requestData == DATA_CONTACT_ID)
            {
                [info setValue:[NSString stringWithFormat:@"%d", currentID] forKey:@"recordID"];
                
                [info setValue:@"" forKey:@"recordIDSelected"];
            }
        }
        
        if ([recordIDs count] > 0)
        {
            BOOL insert = ([[NSString stringWithFormat:@"%d", currentID] isRecordInArray:recordIDs]);
            
            if (insert)
            {
                [allContacts addObject:info];
            }
        }
        else
            [allContacts addObject:info];
        
        [info release];
        if (name) CFRelease(name);
        if (lastNameString) CFRelease(lastNameString);
    }
    
    CFRelease(allPeople);
    CFRelease(addressBook);
    
    if (self.requestData == DATA_CONTACT_TELEPHONE) {
        // Remove people without telephone numbers in the case where
        // that's all we care about
        NSArray* contactsArray = [allContacts allObjects];
        for (NSDictionary *item in contactsArray) {
            
            NSString *str = (NSString *)[item valueForKey:@"telephone"];
            if (!str || [str isEqualToString:@""]) {
                [allContacts removeObject:item];
            }
        }
    }
    
    NSArray* contactsArray = [allContacts allObjects];
    for (NSDictionary *item in contactsArray) //removing duplicates
    {
        NSString *str = (NSString *)[item valueForKey:@"telephone"];
        
        if ([str containsString:@","])
        {
            NSArray *tels = [str componentsSeparatedByString:@","];
            
            for (NSString *i in tels)
            {
                int count = 0;
                
                for (NSDictionary *item in allContacts)
                {
                    NSString *str = (NSString *)[item valueForKey:@"telephone"];
                    
                    if ([str containsString:i])
                        count++;
                }
                
                if (count > 1)
                    [allContacts removeObject:item];
            }
        }
    
    }

    NSSortDescriptor *sorter = [[[NSSortDescriptor alloc] initWithKey:@"name"
                                                            ascending:YES
                                                             selector:@selector(localizedStandardCompare:)] autorelease];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sorter];
    
    NSArray* data = [[allContacts allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    [allContacts release];
   
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
    self.searchDisplayController.searchBar.showsCancelButton = NO;
    
    NSMutableDictionary	*info = [NSMutableDictionary new];
    
    for (int i = 0; i < [arrayLetters count]; i++)
    {
        NSMutableArray *array = [NSMutableArray new];
        
        for (NSDictionary *dict in data)
        {
            NSString *name = [dict valueForKey:@"name"];
            name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if ([[[name substringToIndex:1] uppercaseString] isEqualToString:[arrayLetters objectAtIndex:i]])
            {
                [array addObject:dict];
            }
        }
        
        [info setValue:array forKey:[arrayLetters objectAtIndex:i]];
        [array release];
    }
    
    for (int i = 0; i < [arrayLetters count]; i++)
    {
        NSMutableArray *array = [NSMutableArray new];
        
        for (NSDictionary *dict in data)
        {
            NSString *name = [dict valueForKey:@"name"];
            name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if ((![name isLetterInAlphabet:arrayLetters]) && (![name containsNullString]))
            {
                [array addObject:dict];
            }
        }
        
        [info setValue:array forKey:@"#"];
        [array release];
    }
    
    dataArray = [[NSArray alloc] initWithObjects:info, nil];
  
    self.filteredListContent = [NSMutableArray arrayWithCapacity:[data count]];
    [self.searchDisplayController.searchBar setShowsCancelButton:NO];
    [info release];
    [self.table reloadData];
}

- (void)acceptAction
{
	NSMutableArray *objects = [NSMutableArray new];
    
	for (int i = 0; i < [arrayLetters count]; i++)
	{
		NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];
		
		for (int x = 0; x < [obj count]; x++)
		{
			NSMutableDictionary *item = (NSMutableDictionary *)[obj objectAtIndex:x];
			BOOL checked = [[item objectForKey:@"checked"] boolValue];
            
			if (checked)
			{
                NSString *str = @"";
                
				if (requestData == DATA_CONTACT_TELEPHONE) 
                {
                    str = [item valueForKey:@"telephoneSelected"];
                    
                    if (![str isEqualToString:@""]) 
                    {
                        [objects addObject:str];
                    }
                }
                else if (requestData == DATA_CONTACT_EMAIL)
                {
                    str = [item valueForKey:@"emailSelected"];
                    
                    if (![str isEqualToString:@""]) 
                    {
                        [objects addObject:str];
                    }
                }
                else
                {
                    str = [item valueForKey:@"recordID"];
                    
                    if (![str isEqualToString:@""]) 
                    {
                        [objects addObject:str];
                    }
                }
			}
		}
	}
    
    if ([self.delegate respondsToSelector:@selector(numberOfRowsSelected:withData:andDataType:)]) 
        [self.delegate numberOfRowsSelected:[objects count] withData:objects andDataType:requestData];
    
	[objects release];
	[self dismiss];
}

- (void)dismiss
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		[self tableView:self.searchDisplayController.searchResultsTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else
	{
        if (tableView.tag == kIOS7TableView)
        {
            [selectedItem setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"rowSelected"];
            [alertIOS7 close];
            [telsTable deselectRowAtIndexPath:indexPath animated:YES];

            if (showModal)
            {
                BOOL checked = [[selectedItem objectForKey:@"checked"] boolValue];
                
                [selectedItem setObject:[NSNumber numberWithBool:!checked] forKey:@"checked"];
                
                UITableViewCell *cell = [selectedItem objectForKey:@"cell"];
                UIButton *button = (UIButton *)cell.accessoryView;
                
                UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"];
                [button setBackgroundImage:newImage forState:UIControlStateNormal];
                
                if (tableView == self.searchDisplayController.searchResultsTableView)
                {
                    [self.searchDisplayController.searchResultsTableView reloadData];
                    [selectedRow addObject:selectedItem];
                }
            }
            
            [self postActionSelectRowAtIndex:indexPath.row
                                     section:indexPath.section
                                 withContext:nil
                                        text:[objectsArray objectAtIndex:indexPath.row]
                                     andItem:selectedItem
                                         row:contactRow];
        }
        else
        {
            [self tableView:self.table accessoryButtonTappedForRowWithIndexPath:indexPath];
            [self.table deselectRowAtIndexPath:indexPath animated:YES];
        }
	}	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
    static NSString *kCustomCellID;
    
    if (tableView.tag == kIOS7TableView)
    {
        kCustomCellID = @"iOS7TableView";
        
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCustomCellID];
        
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCustomCellID] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        }

        cell.textLabel.text = [objectsArray objectAtIndex:indexPath.row];
        
        NSInteger rowSelected = [[selectedItem valueForKey:@"rowSelected"] integerValue];
        
        if ((rowSelected != -1) && (indexPath.row == rowSelected))
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        return cell;
    }
    else
    {
        kCustomCellID = @"MyCellID";
        
        cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
        
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCustomCellID] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    }
	
	NSMutableDictionary *item = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        item = (NSMutableDictionary *)[self.filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
		NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:indexPath.section]];
		
		item = (NSMutableDictionary *)[obj objectAtIndex:indexPath.row];
	}
    
	cell.textLabel.text = [item objectForKey:@"name"];
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
	[item setObject:cell forKey:@"cell"];
	
	BOOL checked = [[item objectForKey:@"checked"] boolValue];
	UIImage *image = (checked) ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (!showCheckButton)
        button.hidden = YES;
    else
        button.hidden = NO;
    
	CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	button.frame = frame;
	
	if (tableView == self.searchDisplayController.searchResultsTableView) 
	{
		button.userInteractionEnabled = NO;
	}
	
	[button setBackgroundImage:image forState:UIControlStateNormal];
    
	[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
	cell.backgroundColor = [UIColor clearColor];
	cell.accessoryView = button;
	
	return cell;
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.table];
	NSIndexPath *indexPath = [self.table indexPathForRowAtPoint: currentTouchPosition];
	
	if (indexPath != nil)
	{
		[self tableView:self.table accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{	
	NSMutableDictionary *item = nil;
    
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		item = (NSMutableDictionary *)[filteredListContent objectAtIndex:indexPath.row];
	}
	else
	{
		NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:indexPath.section]];
		item = (NSMutableDictionary *)[obj objectAtIndex:indexPath.row];
	}
    
    objectsArray = nil;
    
    if (requestData == DATA_CONTACT_TELEPHONE)
        objectsArray = [(NSArray *)[[item valueForKey:@"telephone"] componentsSeparatedByString:@","] retain];
    else if (requestData == DATA_CONTACT_EMAIL)
        objectsArray = [(NSArray *)[[item valueForKey:@"email"] componentsSeparatedByString:@","] retain];
    else
        objectsArray = [(NSArray *)[[item valueForKey:@"recordID"] componentsSeparatedByString:@","] retain];

    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    int objectsCount = [objectsArray count];

    if (objectsCount > 1)
    {
        selectedItem = item;
        self.currentTable = tableView;

        if (sysVer >= 7.0)
        {
            contactRow = indexPath.row;
            
            alertIOS7 = [[CustomIOS7AlertView alloc] initWithParentView:self.view];
            
            NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
            
            NSString *cancelString = @"";
            
            if ([language containsString:@"es"])
            {
                cancelString = @"Cancelar";
            }
            else
            {
                cancelString = @"Cancel";
            }
            
            [alertIOS7 setContainerView:[self createTableView]];
            [alertIOS7 setButtonTitles:[NSArray arrayWithObjects:cancelString, nil]];
            [alertIOS7 setDelegate:self];
            [alertIOS7 setUseMotionEffects:true];
            [alertIOS7 setUserInteractionEnabled:YES];
            [alertIOS7 setAutoresizesSubviews:YES];
            [alertIOS7 setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
            [alertIOS7 show];
            [alertIOS7 setClipsToBounds:YES];
        }
        else
        {
            alertTable = [[AlertTableView alloc] initWithCaller:self
                                                           data:objectsArray
                                                          title:alertTitle
                                                        context:self
                                                     dictionary:item
                                                        section:indexPath.section
                                                            row:indexPath.row];
            alertTable.isModal = showModal;
            [alertTable show];
            [alertTable release];
        }
    }
    else
    {
        if (showModal)
        {
            BOOL checked = [[item objectForKey:@"checked"] boolValue];
            
            [item setObject:[NSNumber numberWithBool:!checked] forKey:@"checked"];
            
            UITableViewCell *cell = [item objectForKey:@"cell"];
            UIButton *button = (UIButton *)cell.accessoryView;
            
            UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"];
            [button setBackgroundImage:newImage forState:UIControlStateNormal];
            
            if (tableView == self.searchDisplayController.searchResultsTableView)
            {
                [self.searchDisplayController.searchResultsTableView reloadData];
                [selectedRow addObject:item];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(numberOfRowsSelected:withData:andDataType:)])
            {
                [self.delegate numberOfRowsSelected:1
                                           withData:[NSArray arrayWithObject:[item valueForKey:@"telephoneSelected"]]
                                        andDataType:requestData];
            }
        }
    }
}

#pragma mark -
#pragma mark Custom view iOS7

- (UIView *)createTableView
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    contentView.backgroundColor = [UIColor clearColor];
    
    NSString *currentLanguage = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0] lowercaseString];
    
    NSString *titleAlert = @"";
    
    if ([currentLanguage isEqualToString:@"es"])
	{
        titleAlert = @"Selecciona";
	}
	else
	{
        titleAlert = @"Select";
	}
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 30)];
    labelTitle.text = titleAlert;
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.font = [UIFont boldSystemFontOfSize:15];
    
    [contentView addSubview:labelTitle];
    [labelTitle release];
    
    telsTable = [[UITableView alloc] initWithFrame:CGRectMake(11, labelTitle.frame.size.height + 10, contentView.frame.size.width - 22, 150) style:UITableViewStylePlain];
    
    telsTable.backgroundColor = [UIColor whiteColor];
    
    if ([objectsArray count] < 5)
    {
        telsTable.scrollEnabled = NO;
    }
    
    telsTable.delegate = self;
    telsTable.dataSource = self;
    
    telsTable.tag = kIOS7TableView;
    [contentView addSubview:telsTable];
    [telsTable reloadData];
    
    return [contentView autorelease];
}

#pragma mark
#pragma mark AlertTableViewDelegate delegate method

- (void)didSelectRowAtIndex:(NSInteger)row 
                    section:(NSInteger)section
                withContext:(id)context
                       text:(NSString *)text 
                    andItem:(NSMutableDictionary *)item
                        row:(int)rowSelected
{
    [self postActionSelectRowAtIndex:row section:section withContext:context text:text andItem:item row:rowSelected];
}

- (void)postActionSelectRowAtIndex:(NSInteger)row
                           section:(NSInteger)section
                       withContext:(id)context
                              text:(NSString *)text
                           andItem:(NSMutableDictionary *)item
                               row:(int)rowSelected
{
    if ([text isEqualToString:@"-1"])
    {
        selectedItem = nil;
        return;
    }
    else if ([text isEqualToString:@"-2"])
    {
        (requestData == DATA_CONTACT_TELEPHONE) ? [selectedItem setValue:@"" forKey:@"telephoneSelected"] : [selectedItem setValue:@"" forKey:@"emailSelected"];
        [selectedItem setObject:[NSNumber numberWithBool:NO] forKey:@"checked"];
        [selectedItem setValue:@"-1" forKey:@"rowSelected"];
        UITableViewCell *cell = [selectedItem objectForKey:@"cell"];
        UIButton *button = (UIButton *)cell.accessoryView;
        
        UIImage *newImage = [UIImage imageNamed:@"unchecked.png"];
        [button setBackgroundImage:newImage forState:UIControlStateNormal];
    }
    else
    {
        (requestData == DATA_CONTACT_TELEPHONE) ? [selectedItem setValue:text forKey:@"telephoneSelected"] : [selectedItem setValue:text forKey:@"emailSelected"];
        [selectedItem setObject:[NSNumber numberWithBool:YES] forKey:@"checked"];
        
        UITableViewCell *cell = [selectedItem objectForKey:@"cell"];
        UIButton *button = (UIButton *)cell.accessoryView;
        
        UIImage *newImage = [UIImage imageNamed:@"checked.png"];
        [button setBackgroundImage:newImage forState:UIControlStateNormal]; 
        [button reloadInputViews];
        
        if (self.currentTable == self.searchDisplayController.searchResultsTableView)
        {
            [self.searchDisplayController.searchResultsTableView reloadData];
            [selectedRow addObject:selectedItem];
        }
    }
    
    if (self.currentTable == self.searchDisplayController.searchResultsTableView)
	{
        [filteredListContent replaceObjectAtIndex:rowSelected withObject:item];
	}
	else
	{
		NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:section]];
		[obj replaceObjectAtIndex:rowSelected withObject:item];
	}
    
    selectedItem = nil;
    
    if (!showModal) 
    {
        if ([self.delegate respondsToSelector:@selector(numberOfRowsSelected:withData:andDataType:)])
        {
            [self.delegate numberOfRowsSelected:1 
                                       withData:[NSArray arrayWithObject:[item valueForKey:@"telephoneSelected"]]
                                    andDataType:requestData];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (tableView.tag == kIOS7TableView)
        return [objectsArray count];
    
	if (tableView == self.searchDisplayController.searchResultsTableView)
        return [self.filteredListContent count];
	
	int i = 0;
	NSString *sectionString = [arrayLetters objectAtIndex:section];
	
	NSArray *array = (NSArray *)[[dataArray objectAtIndex:0] valueForKey:sectionString];
    
	for (NSDictionary *dict in array)
	{
		NSString *name = [dict valueForKey:@"name"];
		name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
		
		if (![name isLetterInAlphabet:arrayLetters])
		{
			i++;
		}
		else
		{
			if ([[[name substringToIndex:1] uppercaseString] isEqualToString:[arrayLetters objectAtIndex:section]]) 
			{
				i++;
			}
		}
	}
	
	return i;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
	if ((tableView == self.searchDisplayController.searchResultsTableView) ||
        (tableView.tag == kIOS7TableView))
	{
        return nil;
    }
	
    return arrayLetters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if ((tableView == self.searchDisplayController.searchResultsTableView) ||
        (tableView.tag == kIOS7TableView))
	{
        return 0;
    }
	
    return [arrayLetters indexOfObject:title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ((tableView == self.searchDisplayController.searchResultsTableView) ||
        (tableView.tag == kIOS7TableView))
	{
        return 1;
    }
	
	return [arrayLetters count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{	
	if ((tableView == self.searchDisplayController.searchResultsTableView) ||
        (tableView.tag == kIOS7TableView))
	{
        return @"";
    }
	
	return [arrayLetters objectAtIndex:section];
}

#pragma mark -
#pragma mark Content Filtering

- (void)displayChanges:(BOOL)yesOrNO
{
	int elements = [filteredListContent count];
	NSMutableArray *selected = [NSMutableArray new];
	for (int i = 0; i < elements; i++)
	{
		NSMutableDictionary *item = (NSMutableDictionary *)[filteredListContent objectAtIndex:i];
		
		BOOL checked = [[item objectForKey:@"checked"] boolValue];
		
		if (checked)
		{
			[selected addObject:item];
		}
	}
	
	for (int i = 0; i < [arrayLetters count]; i++)
	{
		NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];
		
		for (int x = 0; x < [obj count]; x++)
		{
			NSMutableDictionary *item = (NSMutableDictionary *)[obj objectAtIndex:x];
            
			if (yesOrNO)
			{
				for (NSDictionary *d in selected)
				{
					if (d == item)
					{
						[item setObject:[NSNumber numberWithBool:yesOrNO] forKey:@"checked"];
					}
				}
			}
			else 
			{
				for (NSDictionary *d in selectedRow)
				{
					if (d == item)
					{
						[item setObject:[NSNumber numberWithBool:yesOrNO] forKey:@"checked"];
					}
				}
			}
		}
	}
	
	[selected release];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
	selectedRow = [NSMutableArray new];
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	selectedRow = nil;
	[self displayChanges:NO];
	[self.searchDisplayController setActive:NO];
	[self.table reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	[self displayChanges:YES];
	[self.searchDisplayController setActive:NO];
	[self.table reloadData];
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString*)scope
{
	[self.filteredListContent removeAllObjects];
    
	for (int i = 0; i < [arrayLetters count]; i++)
	{
		NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];
		
		for (int x = 0; x < [obj count]; x++)
		{
			NSMutableDictionary *item = (NSMutableDictionary *)[obj objectAtIndex:x];
			
			NSString *name = [[item valueForKey:@"name"] lowercaseString];
			name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
			
			NSComparisonResult result = [name compare:[searchText lowercaseString] options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
			if (result == NSOrderedSame)
			{
				[self.filteredListContent addObject:item];
			}
		}
	}
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        if (alertIOS7 != nil)
        {
            NSLog(@"landscape");
            [alertIOS7 layoutSubviews];
            [alertIOS7 layoutIfNeeded];
        }
    }
    else
    {
        if (alertIOS7 != nil)
        {
            [alertIOS7 layoutSubviews];
            [alertIOS7 layoutIfNeeded];
            NSLog(@"portrait again!");
        }
    }
}

#pragma mark -
#pragma mark CustomIOS7AlertViewDelegate methods

- (void)customIOS7dialogButtonTouchUpInside:(CustomIOS7AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView close];
}

- (void)dealloc
{
    [dataArray release];
    [objectsArray release];
    [telsTable release];
	self.filteredListContent = nil;
    self.arrayLetters = nil;
	[super dealloc];
}

@end