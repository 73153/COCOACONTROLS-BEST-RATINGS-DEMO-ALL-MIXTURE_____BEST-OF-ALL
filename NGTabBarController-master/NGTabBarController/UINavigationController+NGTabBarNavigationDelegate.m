//
//  UINavigationController+NGTabBarNavigationDelegate.m
//  NGTabBarController
//
//  Created by Tretter Matthias on 21.05.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "UINavigationController+NGTabBarNavigationDelegate.h"
#import <objc/runtime.h>


static char originalDelegateKey;


@implementation UINavigationController (NGTabBarNavigationDelegate)

- (void)ng_setOriginalNavigationControllerDelegate:(id<UINavigationControllerDelegate>)ng_originalNavigationControllerDelegate {
    objc_setAssociatedObject(self, &originalDelegateKey, ng_originalNavigationControllerDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<UINavigationControllerDelegate>)ng_originalNavigationControllerDelegate {
    return objc_getAssociatedObject(self, &originalDelegateKey);
}

@end
