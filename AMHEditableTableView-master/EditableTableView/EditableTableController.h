//
//  EditableTableController.h
//  Edit Demo
//
//  Created by Alfred Hanssen on 8/15/14.
//  Copyright (c) 2014 Alfie Hanssen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Note: This class currently supports single section tableViews only

@class EditableTableController;

@protocol EditableTableControllerDelegate <NSObject>

@required

- (void)editableTableController:(EditableTableController *)controller
 willBeginMovingCellAtIndexPath:(NSIndexPath *)indexPath;

- (void)editableTableController:(EditableTableController *)controller
  movedCellWithInitialIndexPath:(NSIndexPath *)initialIndexPath
             fromAboveIndexPath:(NSIndexPath *)fromIndexPath
               toAboveIndexPath:(NSIndexPath *)toIndexPath;

- (BOOL)editableTableController:(EditableTableController *)controller
shouldMoveCellFromInitialIndexPath:(NSIndexPath *)initialIndexPath
            toProposedIndexPath:(NSIndexPath *)proposedIndexPath
          withSuperviewLocation:(CGPoint)location;

- (void)editableTableController:(EditableTableController *)controller
didMoveCellFromInitialIndexPath:(NSIndexPath *)initialIndexPath
                    toIndexPath:(NSIndexPath *)toIndexPath;

@end

@interface EditableTableController : NSObject

@property (nonatomic, weak) id<EditableTableControllerDelegate> delegate;
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

@property (nonatomic, weak) UIView *superview; // Optional, tableView will be used as snapshot superview if not set

- (instancetype)initWithTableView:(UITableView *)tableView;

@end
