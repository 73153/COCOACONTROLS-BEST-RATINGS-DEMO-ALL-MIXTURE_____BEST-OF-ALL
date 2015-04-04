#import "NGTabBarItem.h"


#define kNGDefaultTintColor                 [UIColor colorWithRed:41.0/255.0 green:147.0/255.0 blue:239.0/255.0 alpha:1.0]
#define kNGDefaultTitleColor                [UIColor lightGrayColor]
#define kNGDefaultSelectedTitleColor        [UIColor whiteColor]
#define kNGImageOffset                       5.f

@interface NGTabBarItem () {
    BOOL _selectedByUser;
}

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation NGTabBarItem

@synthesize selected = _selected;
@synthesize selectedImageTintColor = _selectedImageTintColor;
@synthesize titleColor = _titleColor;
@synthesize selectedTitleColor = _selectedTitleColor;
@synthesize image = _image;
@synthesize selectedImage = _selectedImage;
@synthesize titleLabel = _titleLabel;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (NGTabBarItem *)itemWithTitle:(NSString *)title image:(UIImage *)image {
    NGTabBarItem *item = [[NGTabBarItem alloc] initWithFrame:CGRectZero];
    
    item.title = title;
    item.image = image;
    
    return item;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        
        _selectedByUser = NO;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:10.f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = kNGDefaultTitleColor;
        [self addSubview:_titleLabel];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.image != nil) {
        CGFloat imageOffset = self.title.length > 0 ? kNGImageOffset : 0.f;
        CGFloat textTop = floor((self.bounds.size.height - self.image.size.height)/2.f) - imageOffset + self.image.size.height + 2.f;
        
        self.titleLabel.frame = CGRectMake(0.f, textTop, self.bounds.size.width, self.titleLabel.font.lineHeight);
    } else {
        self.titleLabel.frame = self.bounds;
    }
}

- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw image overlay?
    if (self.image != nil) {
        CGContextSaveGState(context);
        
        // flip the coordinates system
        CGContextTranslateCTM(context, 0.f, bounds.size.height);
        CGContextScaleCTM(context, 1.f, -1.f);
        
        // draw an image in the center of the cell (offset to the top)
        CGSize imageSize = self.image.size;
        CGFloat imageOffset = self.title.length > 0 ? kNGImageOffset : 0.f;
        CGRect imageRect = CGRectMake(floorf(((bounds.size.width-imageSize.width)/2.f)),
                                      floorf(((bounds.size.height-imageSize.height)/2.f)) + imageOffset,
                                      imageSize.width,
                                      imageSize.height);
        
        // draw either a selection gradient/glow or a regular image
        if (_selectedByUser) {
            if (self.selectedImage != nil) {
                CGContextDrawImage(context, imageRect, self.selectedImage.CGImage);
            }
            else {
                // default to shadow + gradient
                // setup shadow
                CGSize shadowOffset = CGSizeMake(0.0f, 1.0f);
                CGFloat shadowBlur = 3.0;
                CGColorRef cgShadowColor = [[UIColor blackColor] CGColor];
                
                // setup gradient
                CGFloat alpha0 = 0.8;
                CGFloat alpha1 = 0.6;
                CGFloat alpha2 = 0.0;
                CGFloat alpha3 = 0.1;
                CGFloat alpha4 = 0.5;
                CGFloat locations[5] = {0,0.55,0.55,0.7,1};
                
                CGFloat components[20] = {1,1,1,alpha0,1,1,1,alpha1,1,1,1,alpha2,1,1,1,alpha3,1,1,1,alpha4};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGGradientRef colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, (size_t)5);
                CGColorSpaceRelease(colorSpace);
                
                // set shadow
                CGContextSetShadowWithColor(context, shadowOffset, shadowBlur, cgShadowColor);
                
                // set transparency layer and clip to mask
                CGContextBeginTransparencyLayer(context, NULL);
                CGContextClipToMask(context, imageRect, [self.image CGImage]);
                
                // fill and end the transparency layer
                CGContextSetFillColorWithColor(context, [self.selectedImageTintColor CGColor]);
                CGContextFillRect(context, imageRect);
                CGPoint start = CGPointMake(CGRectGetMidX(imageRect), imageRect.origin.y);
                CGPoint end = CGPointMake(CGRectGetMidX(imageRect)-imageRect.size.height/4, imageRect.size.height+imageRect.origin.y);
                CGContextDrawLinearGradient(context, colorGradient, end, start, 0);
                CGContextEndTransparencyLayer(context);
                
                CGGradientRelease(colorGradient);
            }
        } else {
            CGContextDrawImage(context, imageRect, self.image.CGImage);
        }
        
        CGContextRestoreGState(context);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIControl
////////////////////////////////////////////////////////////////////////

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    // somehow self.selected always returns NO, so we store it in our own iVar
    _selectedByUser = selected;
    
    if (selected) {
        self.titleLabel.textColor = self.selectedTitleColor;
    } else {
        self.titleLabel.textColor = self.titleColor;
    }
    
    [self setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGTabBarItem
////////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (UIColor *)selectedImageTintColor {
    return _selectedImageTintColor ?: kNGDefaultTintColor;
}

- (UIColor *)titleColor {
    return _titleColor ?: kNGDefaultTitleColor;
}

- (UIColor *)selectedTitleColor {
    return _selectedTitleColor ?: kNGDefaultSelectedTitleColor;
}

@end
