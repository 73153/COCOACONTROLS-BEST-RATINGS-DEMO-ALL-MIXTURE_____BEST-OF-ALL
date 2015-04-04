//
//  EditableTableController.m
//  Edit Demo
//
//  Created by Alfred Hanssen on 8/15/14.
//  Copyright (c) 2014 Alfie Hanssen. All rights reserved.
//

#import "EditableTableController.h"

static CGFloat SnapshotZoomScale = 1.1f;
static CGFloat SnapshotInsaneZoomScale = 1.5f;
static CGFloat MinLongPressDuration = 0.30f;
static CGFloat ZoomAnimationDuration = 0.20f;

@interface EditableTableController ()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIView *snapshotView;

@property (nonatomic, strong) NSIndexPath *initialIndexPath;
@property (nonatomic, strong) NSIndexPath *previousIndexPath;

@end

@implementation EditableTableController

- (instancetype)init
{
    NSAssert(NO, @"Use custom initializer");
    return nil;
}

- (instancetype)initWithTableView:(UITableView *)tableView
{
    NSAssert(tableView != nil, @"tableView cannot be nil.");
    NSAssert([tableView numberOfSections] == 1, @"This class currently supports single section tableViews only.");
    NSAssert(tableView.estimatedRowHeight > 0, @"The tableView's estimatedRowHeight must be set.");
    
    self = [super init];
    if (self)
    {
        _enabled = YES;
        _tableView = tableView;
        
        [self setupGestureRecognizer];
    }
    
    return self;
}

- (void)cancel
{
    self.longPressRecognizer.enabled = NO;
    self.longPressRecognizer.enabled = YES;
}

#pragma mark - Setup

- (void)setupGestureRecognizer
{
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeLongPress:)];
    self.longPressRecognizer.minimumPressDuration = MinLongPressDuration;
    [_tableView addGestureRecognizer:self.longPressRecognizer];
}

#pragma mark - Accessors

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled != enabled)
    {
        _enabled = enabled;
        
        self.longPressRecognizer.enabled = enabled;
    }
}

#pragma mark - Superview Logic

- (UIView *)snapshotSuperview
{
    if (self.superview)
    {
        return self.superview;
    }
    
    return self.tableView;
}

- (CGRect)rectInSuperview:(CGRect)rect
{
    return [self.tableView convertRect:rect toView:[self snapshotSuperview]];
}

- (CGPoint)pointInSuperview:(CGPoint)point
{
    return [self.tableView convertPoint:point toView:[self snapshotSuperview]];
}

#pragma mark - Gestures

- (void)didRecognizeLongPress:(UILongPressGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:recognizer.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if (indexPath == nil)
        {
            [self cancel];
            return;
        }
        
        self.initialIndexPath = indexPath;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
        rect = [self rectInSuperview:rect];
        
        self.snapshotView = [cell snapshotViewAfterScreenUpdates:NO];
        self.snapshotView.frame = CGRectOffset(self.snapshotView.bounds, rect.origin.x, rect.origin.y);
        [[self snapshotSuperview] addSubview:self.snapshotView];
        
        // Trigger animation...
        CGPoint snapshotLocation = [self pointInSuperview:location];
        [UIView animateWithDuration:ZoomAnimationDuration animations:^{
            self.snapshotView.transform = CGAffineTransformMakeScale(SnapshotZoomScale, SnapshotZoomScale);
            self.snapshotView.center = CGPointMake(self.tableView.center.x, snapshotLocation.y);
        }];
        
        // ...before modifying tableView
        if (self.delegate && [self.delegate respondsToSelector:@selector(editableTableController:willBeginMovingCellAtIndexPath:)])
        {
            [self.delegate editableTableController:self willBeginMovingCellAtIndexPath:indexPath];
        }
        
        self.previousIndexPath = indexPath;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint snapshotLocation = [self pointInSuperview:location];
        self.snapshotView.center = (CGPoint){self.tableView.center.x, snapshotLocation.y};
        
        // Only notify delegate upon moving above a new cell
        if (self.previousIndexPath && indexPath && ![self.previousIndexPath isEqual:indexPath])
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(editableTableController:movedCellWithInitialIndexPath:fromAboveIndexPath:toAboveIndexPath:)])
            {
                [self.delegate editableTableController:self movedCellWithInitialIndexPath:self.initialIndexPath fromAboveIndexPath:self.previousIndexPath toAboveIndexPath:indexPath];
            }
        }
        
        self.previousIndexPath = indexPath;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint snapshotLocation = [self pointInSuperview:location];
        self.snapshotView.center = (CGPoint){self.tableView.center.x, snapshotLocation.y};
        
        // Check if the cell being moved is above the first cell or below the last
        if (indexPath == nil)
        {
            CGFloat cellHeight = [self.tableView estimatedRowHeight];
            NSInteger count = [self.tableView numberOfRowsInSection:0];
            if (location.y > count * cellHeight)
            {
                indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
            }
            else if (location.y <= 0)
            {
                indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            }
        }
        
        BOOL shouldMoveCell = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(editableTableController:shouldMoveCellFromInitialIndexPath:toProposedIndexPath:withSuperviewLocation:)])
        {
            shouldMoveCell = [self.delegate editableTableController:self shouldMoveCellFromInitialIndexPath:self.initialIndexPath toProposedIndexPath:indexPath withSuperviewLocation:snapshotLocation];
        }
        
        if (!shouldMoveCell)
        {
            [UIView animateWithDuration:ZoomAnimationDuration animations:^{
                
                self.snapshotView.transform = CGAffineTransformMakeScale(SnapshotInsaneZoomScale, SnapshotInsaneZoomScale);
                self.snapshotView.alpha = 0.0f;
                
            } completion:^(BOOL finished) {
                
                [self.snapshotView removeFromSuperview];
                self.snapshotView = nil;
                
                self.initialIndexPath = nil;
                self.previousIndexPath = nil;
                
            }];
            
            return;
        }
        
        CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
        rect = [self rectInSuperview:rect];
        
        [UIView animateWithDuration:ZoomAnimationDuration animations:^{
            self.snapshotView.transform = CGAffineTransformIdentity;
            self.snapshotView.center = (CGPoint){CGRectGetMidX(rect), CGRectGetMidY(rect)};
        } completion:^(BOOL finished) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(editableTableController:didMoveCellFromInitialIndexPath:toIndexPath:)])
            {
                [self.delegate editableTableController:self didMoveCellFromInitialIndexPath:self.initialIndexPath toIndexPath:indexPath];
            }
            
            [self.snapshotView removeFromSuperview];
            self.snapshotView = nil;
            
            self.initialIndexPath = nil;
            self.previousIndexPath = nil;
        }];
    }
}

@end
