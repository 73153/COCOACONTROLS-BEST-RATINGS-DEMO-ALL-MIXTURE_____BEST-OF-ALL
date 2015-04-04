//
//  SpecialCaseViewController.m
//  KeyboardTextFieldDemo

#import "SpecialCaseViewController.h"
#import "IQUIView+Hierarchy.h"

@interface SpecialCaseViewController ()<UISearchBarDelegate,UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate>

@end

@implementation SpecialCaseViewController
{
    IBOutlet UITextField *customWorkTextField;
    
    IBOutlet UITextField *textField6;
    IBOutlet UITextField *textField7;
    IBOutlet UITextField *textField8;
    
    IBOutlet UISwitch *switchInteraction1;
    IBOutlet UISwitch *switchInteraction2;
    IBOutlet UISwitch *switchInteraction3;
    IBOutlet UISwitch *switchEnabled1;
    IBOutlet UISwitch *switchEnabled2;
    IBOutlet UISwitch *switchEnabled3;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    textField6.userInteractionEnabled = switchInteraction1.on;
    textField7.userInteractionEnabled = switchInteraction2.on;
    textField8.userInteractionEnabled = switchInteraction3.on;

    textField6.enabled = switchEnabled1.on;
    textField7.enabled = switchEnabled2.on;
    textField8.enabled = switchEnabled3.on;
    
    [self updateUI];
}

- (IBAction)showAlertClicked:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"IQKeyboardManager" message:@"It doesn't affect UIAlertView (Doesn't add IQToolbar on it's textField" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alertView show];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)updateUI
{
    textField6.placeholder = [NSString stringWithFormat:@"%@, %@",textField6.enabled?@"enabled":@"",textField6.userInteractionEnabled?@"userInteractionEnabled":@""];
    textField7.placeholder = [NSString stringWithFormat:@"%@, %@",textField7.enabled?@"enabled":@"",textField7.userInteractionEnabled?@"userInteractionEnabled":@""];
    textField8.placeholder = [NSString stringWithFormat:@"%@, %@",textField8.enabled?@"enabled":@"",textField8.userInteractionEnabled?@"userInteractionEnabled":@""];
}

- (IBAction)switch1UserInteractionAction:(UISwitch *)sender
{
    textField6.userInteractionEnabled = sender.on;
    [self updateUI];
}

- (IBAction)switch2UserInteractionAction:(UISwitch *)sender
{
    textField7.userInteractionEnabled = sender.on;
    [self updateUI];
}

- (IBAction)switch3UserInteractionAction:(UISwitch *)sender
{
    textField8.userInteractionEnabled = sender.on;
    [self updateUI];
}

- (IBAction)switch1Action:(UISwitch *)sender
{
    textField6.enabled = sender.on;
    [self updateUI];
}

- (IBAction)switch2Action:(UISwitch *)sender
{
    textField7.enabled = sender.on;
    [self updateUI];
}

- (IBAction)switch3Action:(UISwitch *)sender
{
    textField8.enabled = sender.on;
    [self updateUI];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == customWorkTextField)
    {
        if (textField.isAskingCanBecomeFirstResponder == NO)
        {
//            UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:@"test" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//            [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            }]];
//            [self presentViewController:actionSheet animated:YES completion:nil];

////            //Do your work on tapping textField.
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"IQKeyboardManager" message:@"Do your custom work here" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView show];
        }

        return NO;
    }
    else    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switchEnabled1.enabled = NO;
    switchEnabled2.enabled = NO;
    switchEnabled3.enabled = NO;
    switchInteraction1.enabled = NO;
    switchInteraction2.enabled = NO;
    switchInteraction3.enabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switchEnabled1.enabled = YES;
    switchEnabled2.enabled = YES;
    switchEnabled3.enabled = YES;
    switchInteraction1.enabled = YES;
    switchInteraction2.enabled = YES;
    switchInteraction3.enabled = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}
@end
