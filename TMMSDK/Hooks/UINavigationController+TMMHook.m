//
//  UINavigationController+TMMHook.m
//  TMMSDK
//
//  Created by Syd on 2018/7/27.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <objc/runtime.h>
#import "UINavigationController+TMMHook.h"
#import "TMMHookHelper.h"

@implementation UINavigationController (TMMHook)

+ (void)hookUINavigationController_push
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method pushMethod = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
        Method hookMethod = class_getInstanceMethod([self class], @selector(hook_pushViewController:animated:));
        method_exchangeImplementations(pushMethod, hookMethod);
    });
}


- (void)hook_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"t": [NSNumber numberWithInteger:round(ts)], @"c": NSStringFromClass([self class]), @"a": @"pushViewController", @"v": NSStringFromClass([viewController class]) }];
    });
    [self hook_pushViewController:viewController animated:animated];
}


+ (void)hookUINavigationController_pop
{
    Method popMethod = class_getInstanceMethod([self class], @selector(popViewControllerAnimated:));
    Method hookMethod = class_getInstanceMethod([self class], @selector(hook_popViewControllerAnimated:));
    method_exchangeImplementations(popMethod, hookMethod);
}


- (void)hook_popViewControllerAnimated:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"t": [NSNumber numberWithInteger:round(ts)], @"c": NSStringFromClass([self class]), @"v": @"popViewController" }];
    });
    [self hook_popViewControllerAnimated:animated];
}

@end
