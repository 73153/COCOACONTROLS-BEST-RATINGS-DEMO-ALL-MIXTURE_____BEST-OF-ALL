//
//  ViewController.m
//  EditableTableView
//
//  Created by Alfred Hanssen on 8/16/14.
//  Copyright (c) 2014 alfiehanssen. All rights reserved.
//

#import "ViewController.h"
#import "EditableTableController.h"

static CGFloat CellHeight = 44.0f;
static NSString *CellIdentifier = @"CellIdentifier";

static NSInteger NumberOfItems = 10;
static NSString *PlaceholderItem = @"com.alfiehanssen.item_placeholder";
static NSString *Item = @"com.alfiehanssen.item_%i";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, EditableTableControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) EditableTableController *editableTableController;
@property (nonatomic, strong) NSString *itemBeingMoved;
@property (nonatomic, strong) NSString *placeholderItem;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _itemBeingMoved = nil;
        _placeholderItem = PlaceholderItem;
        _items = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupDatasource];
    [self setupTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup

- (void)setupDatasource
{
    for (NSInteger i = 0; i < NumberOfItems; i++)
    {
        NSString *item = [NSString stringWithFormat:Item, i];
        [_items addObject:item];
    }
}

- (void)setupTableView
{
    self.tableView.estimatedRowHeight = CellHeight;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    self.editableTableController = [[EditableTableController alloc] initWithTableView:self.tableView];
    self.editableTableController.delegate = self;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString *item = [self.items objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item;
    
    return cell;
}

#pragma mark - EditableTableViewDelegate

- (void)editableTableController:(EditableTableController *)controller willBeginMovingCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    self.itemBeingMoved = [self.items objectAtIndex:indexPath.row];
    [self.items replaceObjectAtIndex:indexPath.row withObject:self.placeholderItem];
    
    [self.tableView endUpdates];
}

- (void)editableTableController:(EditableTableController *)controller movedCellWithInitialIndexPath:(NSIndexPath *)initialIndexPath fromAboveIndexPath:(NSIndexPath *)fromIndexPath toAboveIndexPath:(NSIndexPath *)toIndexPath
{
    [self.tableView beginUpdates];
    
    [self.tableView moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
    
    NSString *item = [self.items objectAtIndex:toIndexPath.row];
    [self.items removeObjectAtIndex:toIndexPath.row];
    
    if (fromIndexPath.row == [self.items count])
    {
        [self.items addObject:item];
    }
    else
    {
        [self.items insertObject:item atIndex:fromIndexPath.row];
    }
    
    [self.tableView endUpdates];
}

- (BOOL)editableTableController:(EditableTableController *)controller shouldMoveCellFromInitialIndexPath:(NSIndexPath *)initialIndexPath toProposedIndexPath:(NSIndexPath *)proposedIndexPath withSuperviewLocation:(CGPoint)location
{
    CGRect exampleRect = (CGRect){0, 0, self.view.bounds.size.width, 44.0f};
    if (CGRectContainsPoint(exampleRect, location))
    {
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:@[proposedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.items removeObjectAtIndex:proposedIndexPath.row];
        
        [self.tableView endUpdates];
        
        self.itemBeingMoved = nil;

        return NO;
    }
    
    return YES;
}

- (void)editableTableController:(EditableTableController *)controller didMoveCellFromInitialIndexPath:(NSIndexPath *)initialIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.items replaceObjectAtIndex:toIndexPath.row withObject:self.itemBeingMoved];
    
    [self.tableView reloadRowsAtIndexPaths:@[toIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    self.itemBeingMoved = nil;
}

@end
