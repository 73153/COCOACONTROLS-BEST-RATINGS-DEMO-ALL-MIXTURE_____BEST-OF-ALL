//
//  UINavigationController+NGTabBarNavigationDelegate.h
//  NGTabBarController
//
//  Created by Tretter Matthias on 21.05.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (NGTabBarNavigationDelegate)

@property (nonatomic, assign, setter = ng_setOriginalNavigationControllerDelegate:) id<UINavigationControllerDelegate> ng_originalNavigationControllerDelegate;

@end
