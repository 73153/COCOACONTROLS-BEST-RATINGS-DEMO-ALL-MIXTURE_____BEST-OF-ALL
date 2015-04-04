#import "FORMTextFieldCell.h"

#import "FORMTooltipView.h"

static NSString * const FORMHideTooltips = @"FORMHideTooltips";
static const CGFloat FORMTooltipViewMinimumWidth = 90.0f;
static const CGFloat FORMTooltipViewHeight = 44.0f;
static const NSInteger FORMTooltipNumberOfLines = 4;

@interface FORMTextFieldCell () <FORMTextFieldDelegate>

@property (nonatomic) FORMTextField *textField;
@property (nonatomic) UIPopoverController *popoverController;
@property (nonatomic) UILabel *tooltipLabel;
@property (nonatomic) FORMTooltipView *tooltipView;
@property (nonatomic) BOOL showTooltips;

@end

@implementation FORMTextFieldCell

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    [self.contentView addSubview:self.textField];

    if ([self respondsToSelector:@selector(resignFirstResponder)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resignFirstResponder)
                                                     name:FORMResignFirstResponderNotification
                                                   object:nil];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissTooltip)
                                                 name:FORMDismissTooltipNotification
                                               object:nil];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapAction)];
    [self addGestureRecognizer:tapGestureRecognizer];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTooltip:)
                                                 name:FORMHideTooltips
                                               object:nil];

    return self;
}

- (void)dealloc
{
    if ([self respondsToSelector:@selector(dismissTooltip)]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:FORMResignFirstResponderNotification
                                                      object:nil];
    }

    if ([self respondsToSelector:@selector(showTooltip:)]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:FORMHideTooltips
                                                      object:nil];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FORMDismissTooltipNotification
                                                  object:nil];
}

#pragma mark - Getters

- (FORMTextField *)textField
{
    if (_textField) return _textField;

    _textField = [[FORMTextField alloc] initWithFrame:[self textFieldFrame]];
    _textField.textFieldDelegate = self;

    return _textField;
}

- (CGRect)labelFrameUsingString:(NSString *)string
{
    NSArray *components = [string componentsSeparatedByString:@"\n"];

    CGFloat width;

    if (components.count > 1) {
        NSString *longestLine;
        for (NSString *line in components) {
            if (longestLine) {
                if (line.length > longestLine.length) {
                    longestLine = line;
                }
            } else {
                longestLine = line;
            }
        }
        width = 8.0f * longestLine.length;
    } else {
        width = 8.0f * string.length;
    }

    if (width < FORMTooltipViewMinimumWidth) width = FORMTooltipViewMinimumWidth;

    CGFloat height = FORMTooltipViewHeight;
    height += 11.0f * components.count;

    return CGRectMake(0, 0, width, height);
}

- (CGRect)tooltipViewFrame
{
    CGRect frame = [self labelFrameUsingString:self.field.info];

    frame.size.height += [FORMTooltipView arrowHeight];
    frame.origin.x = self.textField.frame.origin.x;
    frame.origin.y = self.textField.frame.origin.y;

    frame.origin.x += self.textField.frame.size.width / 2 - frame.size.width / 2;

    if ([self.field.sectionPosition isEqualToNumber:@0]) {
        self.tooltipView.arrowDirection = UIPopoverArrowDirectionUp;
        frame.origin.y += self.textField.frame.size.height / 2;
    } else {
        self.tooltipView.arrowDirection = UIPopoverArrowDirectionDown;
        frame.origin.y -= self.textField.frame.size.height / 2;
        frame.origin.y -= frame.size.height;
    }

    frame.origin.y += [FORMTooltipView arrowHeight];

    return frame;
}

- (FORMTooltipView *)tooltipView
{
    if (_tooltipView) return _tooltipView;

    _tooltipView = [FORMTooltipView new];
    [_tooltipView addSubview:self.tooltipLabel];

    return _tooltipView;
}

- (CGRect)tooltipLabelFrame
{
    CGRect frame = [self labelFrameUsingString:self.field.info];

    if (self.tooltipView.arrowDirection == UIPopoverArrowDirectionUp) {
        frame.origin.y += [FORMTooltipView arrowHeight];
    }

    return frame;
}

- (UILabel *)tooltipLabel
{
    if (_tooltipLabel) return _tooltipLabel;

    _tooltipLabel = [[UILabel alloc] initWithFrame:[self labelFrameUsingString:@""]];

    _tooltipLabel.textAlignment = NSTextAlignmentCenter;
    _tooltipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _tooltipLabel.numberOfLines = FORMTooltipNumberOfLines;

    return _tooltipLabel;
}

#pragma mark - FORMBaseFormFieldCell

- (void)updateFieldWithDisabled:(BOOL)disabled
{
    self.textField.enabled = !disabled;
}

- (void)updateWithField:(FORMField *)field
{
    [super updateWithField:field];

    self.textField.hidden          = (field.sectionSeparator);
    self.textField.inputValidator  = [self.field inputValidator];
    self.textField.formatter       = [self.field formatter];
    self.textField.typeString      = field.typeString;
    self.textField.inputTypeString = field.inputTypeString;
    self.textField.enabled         = !field.disabled;
    self.textField.valid           = field.valid;
    self.textField.rawText         = [self rawTextForField:field];
    self.textField.info   = field.info;
}

- (void)validate
{
    BOOL validation = ([self.field validate] == FORMValidationResultTypePassed);
    [self.textField setValid:validation];
}

#pragma mark - Private methods

- (NSString *)rawTextForField:(FORMField *)field
{
    if (field.value && field.type == FORMFieldTypeFloat) {

        NSNumber *value = field.value;

        if ([field.value isKindOfClass:[NSString class]]) {
            NSMutableString *fieldValue = [field.value mutableCopy];
            [fieldValue replaceOccurrencesOfString:@","
                                        withString:@"."
                                           options:NSCaseInsensitiveSearch
                                             range:NSMakeRange(0, [fieldValue length])];
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            value = [formatter numberFromString:fieldValue];
        }

        return [NSString stringWithFormat:@"%.2f", [value doubleValue]];
    }

    return field.value;
}

#pragma mark - Actions

- (void)cellTapAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FORMDismissTooltipNotification object:nil];

    BOOL shouldDisplayTooltip = (self.field.type == FORMFieldTypeText &&
                                 self.field.info);
    if (shouldDisplayTooltip) {
        [self showTooltip];
    }
}

- (void)focusAction
{
    [self.textField becomeFirstResponder];
}

- (void)clearAction
{
    self.field.value = nil;
    [self updateWithField:self.field];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.textField.frame = [self textFieldFrame];
}

- (CGRect)textFieldFrame
{
    CGFloat marginX = FORMTextFieldCellMarginX;
    CGFloat marginTop = FORMFieldCellMarginTop;
    CGFloat marginBotton = FORMFieldCellMarginBottom;

    CGFloat width  = CGRectGetWidth(self.frame) - (marginX * 2);
    CGFloat height = CGRectGetHeight(self.frame) - marginTop - marginBotton;
    CGRect  frame  = CGRectMake(marginX, marginTop, width, height);

    return frame;
}

- (void)showTooltip
{
    if (self.field.info && self.showTooltips) {
        self.tooltipView.alpha = 0.0f;
        [self.contentView addSubview:self.tooltipView];
        self.tooltipView.frame = [self tooltipViewFrame];
        self.tooltipLabel.frame = [self tooltipLabelFrame];
        [self.superview bringSubviewToFront:self];

        CGRect tooltipViewFrame = self.tooltipView.frame;

        if (self.tooltipView.frame.origin.x < 0) {
            self.tooltipView.arrowOffset = tooltipViewFrame.origin.x;
            tooltipViewFrame.origin.x = 0;
        }

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.field.info];
        NSMutableParagraphStyle *paragrahStyle = [NSMutableParagraphStyle new];
        paragrahStyle.alignment = NSTextAlignmentCenter;
        paragrahStyle.lineSpacing = 8;
        [attributedString addAttribute:NSParagraphStyleAttributeName
                                 value:paragrahStyle
                                 range:NSMakeRange(0, self.field.info.length)];

        self.tooltipLabel.attributedText = attributedString;

        CGFloat windowWidth = self.window.frame.size.width;
        BOOL isOutOfBounds = ((tooltipViewFrame.size.width + self.frame.origin.x) > windowWidth);
        if (isOutOfBounds) {
            tooltipViewFrame.origin.x = windowWidth;
            tooltipViewFrame.origin.x -= tooltipViewFrame.size.width;
            tooltipViewFrame.origin.x -= self.frame.origin.x;

            self.tooltipView.arrowOffset = tooltipViewFrame.size.width / 2;
            self.tooltipView.arrowOffset -= self.textField.frame.size.width / 2;
            self.tooltipView.arrowOffset -= 39.0f;
        }

        self.tooltipView.frame = tooltipViewFrame;

        [UIView animateWithDuration:0.3f animations:^{
            self.tooltipView.alpha = 1.0f;
        }];
    }
}

#pragma mark - FORMTextFieldDelegate

- (void)textFormFieldDidBeginEditing:(FORMTextField *)textField
{
    [self performSelector:@selector(showTooltip) withObject:nil afterDelay:0.1f];
}

- (void)textFormFieldDidEndEditing:(FORMTextField *)textField
{
    [self validate];

    if (!self.textField.valid) {
        [self.textField setValid:[self.field validate]];
    }

    if (self.showTooltips) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FORMDismissTooltipNotification
                                                            object:nil];
    }
}

- (void)textFormField:(FORMTextField *)textField
    didUpdateWithText:(NSString *)text
{
    self.field.value = text;
    [self validate];

    if (!self.textField.valid) {
        [self.textField setValid:[self.field validate]];
    }

    if ([self.delegate respondsToSelector:@selector(fieldCell:updatedWithField:)]) {
        [self.delegate fieldCell:self
                updatedWithField:self.field];
    }
}

#pragma mark - Styling

- (void)setTooltipLabelFont:(UIFont *)tooltipLabelFont
{
    self.tooltipLabel.font = tooltipLabelFont;
}

- (void)setTooltipLabelTextColor:(UIColor *)tooltipLabelTextColor
{
    self.tooltipLabel.textColor = tooltipLabelTextColor;
}

- (void)setTooltipBackgroundColor:(UIColor *)tooltipBackgroundColor
{
    [FORMTooltipView setTintColor:tooltipBackgroundColor];
}

#pragma mark - Notifications

- (void)dismissTooltip
{
    if (self.field.info) {
        [self.tooltipView removeFromSuperview];
    }
}

- (void)showTooltip:(NSNotification *)notification
{
    self.showTooltips = [notification.object boolValue];
}

#pragma mark - Private headers

- (BOOL)resignFirstResponder
{
    [self.textField resignFirstResponder];

    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [self.textField becomeFirstResponder];

    return [super becomeFirstResponder];
}

@end
