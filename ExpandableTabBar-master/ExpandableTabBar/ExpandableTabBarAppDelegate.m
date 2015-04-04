//
//  ExpandableTabBarAppDelegate.m
//
//  Copyright 2011 Brendan Dixon
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE
//

#import "ExpandableTabBarAppDelegate.h"
#import "CiColorController.h"
#import "CiExpandableTabBarController.h"

@implementation ExpandableTabBarAppDelegate

#pragma mark - Properties
@synthesize window=_window;


#pragma mark - Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Create a set of dummy controllers
  NSMutableArray* viewControllers = [[NSMutableArray alloc] init];
  
  NSArray* names = [NSArray arrayWithObjects:@"Red", @"Green", @"Blue", @"Orange", @"Yellow", nil];
  NSArray* colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor orangeColor], [UIColor yellowColor], nil];
  NSArray* images = [NSArray arrayWithObjects:@"Airplane.png", @"Bookmark.png", @"Breifcase.png", @"Chat.png", @"Clock.png", nil];
  NSUInteger total = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 75 : 15);
  for (NSUInteger i=0; i < total; i++) {
    CiColorController* colorController = [[CiColorController alloc] init];
    [viewControllers addObject:colorController];

    colorController.color = [colors objectAtIndex:(i % [colors count])];

    UIImage* image = [UIImage imageNamed:[images objectAtIndex:(i % [images count])]];
    UITabBarItem* tabBarItem = [[UITabBarItem alloc] initWithTitle:[names objectAtIndex:(i % [names count])] image:image tag:0];
    
    [colorController setTabBarItem:tabBarItem];
    [tabBarItem release];
    [colorController release];
  }

  CiExpandableTabBarController* tabBarController = [[CiExpandableTabBarController alloc] initWithViewControllers:viewControllers];
  self.window.rootViewController = tabBarController;

  [tabBarController release];
  [viewControllers release];

  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application {
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}

- (void)dealloc {
  [_window release];
  [super dealloc];
}

@end
