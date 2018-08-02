//
//  UITabBarController+TMMHook.m
//  TMMSDK
//
//  Created by Syd on 2018/7/30.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <objc/runtime.h>
#import "UITabBarController+TMMHook.h"
#import "TMMHookHelper.h"

@implementation UITabBarController (TMMHook)

+ (void)hookUITabBarController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oriMethod = class_getInstanceMethod([self class], @selector(tabBarController:shouldSelectViewController:));
        Method hookMethod = class_getInstanceMethod([self class], @selector(hook_tabBarController:shouldSelectViewController:));
        method_exchangeImplementations(oriMethod, hookMethod);
    });
}

- (void)hook_tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": NSStringFromClass([viewController class]), @"action": @"tabBarController:shouldSelectViewController:" }];
    });
    [self hook_tabBarController:tabBarController shouldSelectViewController:viewController];
}

@end
