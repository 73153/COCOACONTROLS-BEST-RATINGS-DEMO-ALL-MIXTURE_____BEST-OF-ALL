#import "FORMPopoverFieldCell.h"
#import "FORMTextFieldCell.h"

static const CGFloat FORMIconButtonWidth = 32.0f;
static const CGFloat FORMIconButtonHeight = 38.0f;

@interface FORMPopoverFieldCell () <FORMTitleLabelDelegate, UIPopoverControllerDelegate>

@property (nonatomic) UIViewController *contentViewController;
@property (nonatomic) CGSize contentSize;

@end

@implementation FORMPopoverFieldCell

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame contentViewController:(UIViewController *)contentViewController
               andContentSize:(CGSize)contentSize
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    _contentViewController = contentViewController;
    _contentSize = contentSize;

    [self.contentView addSubview:self.fieldValueLabel];
    [self.contentView addSubview:self.iconImageView];

    return self;
}

#pragma mark - Getters

- (FORMFieldValueLabel *)fieldValueLabel
{
    if (_fieldValueLabel) return _fieldValueLabel;

    _fieldValueLabel = [[FORMFieldValueLabel alloc] initWithFrame:[self fieldValueLabelFrame]];
    _fieldValueLabel.delegate = self;

    return _fieldValueLabel;
}

- (UIPopoverController *)popoverController
{
    if (_popoverController) return _popoverController;

    _popoverController = [[UIPopoverController alloc] initWithContentViewController:self.contentViewController];
    _popoverController.delegate = self;
    _popoverController.popoverContentSize = self.contentSize;
    _popoverController.backgroundColor = [UIColor whiteColor];

    return _popoverController;
}

- (UIImageView *)iconImageView
{
    if (_iconImageView) return _iconImageView;

    _iconImageView = [[UIImageView alloc] initWithFrame:[self iconImageViewFrame]];
    _iconImageView.contentMode = UIViewContentModeRight;
    _iconImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    return _iconImageView;
}

#pragma mark - Private methods

- (BOOL)becomeFirstResponder
{
    [self titleLabelPressed:self.fieldValueLabel];

    return [super becomeFirstResponder];
}

#pragma mark - FORMBaseFormFieldCell

- (void)validate
{
    [self.fieldValueLabel setValid:[self.field validate]];
}

#pragma mark - FORMPopoverFormFieldCell

- (void)updateContentViewController:(UIViewController *)contentViewController withField:(FORMField *)field
{
    abort();
}

#pragma mark - FORMBaseFormFieldCell

- (void)updateFieldWithDisabled:(BOOL)disabled
{
    self.fieldValueLabel.enabled = !disabled;
}

- (void)updateWithField:(FORMField *)field
{
    [super updateWithField:field];

    self.iconImageView.hidden = field.disabled;

    self.fieldValueLabel.hidden = (field.sectionSeparator);
    self.fieldValueLabel.enabled = !field.disabled;
    self.fieldValueLabel.userInteractionEnabled = !field.disabled;
    self.fieldValueLabel.valid = field.valid;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.fieldValueLabel.frame = [self fieldValueLabelFrame];
    self.iconImageView.frame = [self iconImageViewFrame];
}

- (CGRect)fieldValueLabelFrame
{
    CGFloat marginX = FORMTextFieldCellMarginX;
    CGFloat marginTop = FORMFieldCellMarginTop;
    CGFloat marginBotton = FORMFieldCellMarginBottom;

    CGFloat width = CGRectGetWidth(self.frame) - (marginX * 2);
    CGFloat height = CGRectGetHeight(self.frame) - marginTop - marginBotton;
    CGRect frame = CGRectMake(marginX, marginTop, width, height);

    return frame;
}

- (CGRect)iconImageViewFrame
{
    CGFloat x = CGRectGetWidth(self.frame) - FORMIconButtonWidth - (FORMTextFieldCellMarginX * 2);
    CGFloat y = FORMIconButtonHeight - 4;
    CGFloat width = FORMIconButtonWidth;
    CGFloat height = FORMIconButtonHeight;
    CGRect frame = CGRectMake(x, y, width, height);

    return frame;
}

#pragma mark - FORMTitleLabelDelegate

- (void)titleLabelPressed:(FORMFieldValueLabel *)titleLabel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FORMResignFirstResponderNotification object:nil];

    [self updateContentViewController:self.contentViewController withField:self.field];

    if (!self.popoverController.isPopoverVisible) {
        [self.popoverController presentPopoverFromRect:self.bounds
                                                inView:self
                              permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                              animated:YES];
    }
}

@end
