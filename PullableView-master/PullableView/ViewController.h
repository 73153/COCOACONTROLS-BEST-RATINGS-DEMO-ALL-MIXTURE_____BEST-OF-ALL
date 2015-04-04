
#import <UIKit/UIKit.h>
#import "StyledPullableView.h"

/**
 Sample view controller
 @author Fabio Rodella fabio@crocodella.com.br
 */

@interface ViewController : UIViewController <PullableViewDelegate> {
    StyledPullableView *pullDownView;
    
    StyledPullableView *pullUpView;
    UILabel *pullUpLabel;
    
    PullableView *pullRightView;
}

@end
