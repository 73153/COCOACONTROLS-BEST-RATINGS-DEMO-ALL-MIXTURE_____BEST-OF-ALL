//
//  AppDelegate.m
//  JBSignatureControllerTest
//
//  Created by Jesse Bunch on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

/**
 * App Init.
 * @author Jesse Bunch
 **/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Initiallize the signature controller
	JBSignatureController *signatureController = [[JBSignatureController alloc] init];
	signatureController.delegate = self;
	[self.window setRootViewController:signatureController];
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
    return YES;
	
}



#pragma mark - *** JBSignatureControllerDelegate ***

/**
 * Example usage of signatureConfirmed:signatureController:
 * @author Jesse Bunch
 **/
-(void)signatureConfirmed:(UIImage *)signatureImage signatureController:(JBSignatureController *)sender {
	
	// get image and close signature controller
	
	// I replaced the view just to show it works...
	UIImageView *imageview = [[UIImageView alloc] initWithImage:signatureImage];
	[imageview setContentMode:UIViewContentModeCenter];
	[imageview sizeToFit];
	[imageview setTransform:sender.view.transform];
	sender.view = imageview;
	
	// Example saving the image in the app's application support directory
	NSString *appSupportPath = [[NSFileManager defaultManager] applicationSupportDirectory];
	[UIImagePNGRepresentation(signatureImage) writeToFile:[appSupportPath stringByAppendingPathComponent:@"signature.png"] atomically:YES];
	
	
}

/**
 * Example usage of signatureCancelled:
 * @author Jesse Bunch
 **/
-(void)signatureCancelled:(JBSignatureController *)sender {
	
	// close signature controller
	
	// Clear the sig for now
	[sender clearSignature];
	
}


@end
