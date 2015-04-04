
#import "ViewController.h"

/**
 @author Fabio Rodella fabio@crocodella.com.br
 */

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat xOffset = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        xOffset = 224;
    }
    
    pullRightView = [[PullableView alloc] initWithFrame:CGRectMake(0, 200, 200, 300)];
    pullRightView.backgroundColor = [UIColor lightGrayColor];
    pullRightView.openedCenter = CGPointMake(100, 200);
    pullRightView.closedCenter = CGPointMake(-70, 200);
    pullRightView.center = pullRightView.closedCenter;
    pullRightView.animate = NO;
    
    pullRightView.handleView.backgroundColor = [UIColor darkGrayColor];
    pullRightView.handleView.frame = CGRectMake(170, 0, 30, 300);
    
    [self.view addSubview:pullRightView];
    [pullRightView release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    label.backgroundColor = [UIColor darkGrayColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"Pull me to the right!";
    label.transform = CGAffineTransformMakeRotation(-M_PI_2);
    label.center = CGPointMake(185, 150);
    
    [pullRightView addSubview:label];
    [label release];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(4, 120, 200, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"I'm not animated";
    
    [pullRightView addSubview:label];
    [label release];
    
    pullUpView = [[StyledPullableView alloc] initWithFrame:CGRectMake(xOffset, 0, 320, 460)];
    pullUpView.openedCenter = CGPointMake(160 + xOffset,self.view.frame.size.height);
    pullUpView.closedCenter = CGPointMake(160 + xOffset, self.view.frame.size.height + 200);
    pullUpView.center = pullUpView.closedCenter;
    pullUpView.handleView.frame = CGRectMake(0, 0, 320, 40);
    pullUpView.delegate = self;
    
    [self.view addSubview:pullUpView];
    [pullUpView release];    
    
    pullUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 320, 20)];
    pullUpLabel.textAlignment = UITextAlignmentCenter;
    pullUpLabel.backgroundColor = [UIColor clearColor];
    pullUpLabel.textColor = [UIColor lightGrayColor];
    pullUpLabel.text = @"Pull me up!";
    
    [pullUpView addSubview:pullUpLabel];
    [pullUpLabel release];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 320, 64)];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(1, 1);
    label.text = @"I only go half-way up!";
    
    [pullUpView addSubview:label];
    [label release];
    
    pullDownView = [[StyledPullableView alloc] initWithFrame:CGRectMake(xOffset, 0, 320, 460)];
    pullDownView.openedCenter = CGPointMake(160 + xOffset,230);
    pullDownView.closedCenter = CGPointMake(160 + xOffset, -200);
    pullDownView.center = pullDownView.closedCenter;
    
    [self.view addSubview:pullDownView];
    [pullDownView release];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 320, 64)];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(1, 1);
    label.text = @"Look at this beautiful linen texture!";
    
    [pullDownView addSubview:label];
    [label release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)pullableView:(PullableView *)pView didChangeState:(BOOL)opened {
    if (opened) {
        pullUpLabel.text = @"Now I'm open!";
    } else {
        pullUpLabel.text = @"Now I'm closed, pull me up again!";
    }
}

@end
