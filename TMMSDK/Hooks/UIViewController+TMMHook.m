//
//  UIViewController+TMMHook.m
//  TMMSDK
//
//  Created by Syd on 2018/7/27.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+TMMHook.h"
#import "TMMHookHelper.h"

@implementation UIViewController (TMMHook)

+ (void)hookUIViewController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method appearMethod = class_getInstanceMethod([self class], @selector(viewDidAppear:));
        Method hookMethod = class_getInstanceMethod([self class], @selector(hook_ViewDidAppear:));
        method_exchangeImplementations(appearMethod, hookMethod);
    });
}


- (void)hook_ViewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"t": [NSNumber numberWithInteger:round(ts)], @"c": NSStringFromClass([self class]), @"a": @"viewDidAppear"}];
    });
    [self hook_ViewDidAppear:animated];
}

@end
