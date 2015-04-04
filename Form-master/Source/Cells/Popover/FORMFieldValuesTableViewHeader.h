@import UIKit;

#import "FORMField.h"

static const CGFloat FORMFieldValuesHeaderWidth = 320.0f;
static const CGFloat FORMFieldValuesHeaderHeight = 66.0f;

static NSString * const FORMFieldValuesTableViewHeaderIdentifier = @"FORMFieldValuesTableViewHeaderIdentifier";

@interface FORMFieldValuesTableViewHeader : UITableViewHeaderFooterView

@property (nonatomic, weak) FORMField *field;

- (void)setTitleLabelFont:(UIFont *)titleLabelFont UI_APPEARANCE_SELECTOR;
- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor UI_APPEARANCE_SELECTOR;
- (void)setInfoLabelFont:(UIFont *)infoLabelFont UI_APPEARANCE_SELECTOR;
- (void)setInfoLabelTextColor:(UIColor *)infoLabelTextColor UI_APPEARANCE_SELECTOR;

@end
