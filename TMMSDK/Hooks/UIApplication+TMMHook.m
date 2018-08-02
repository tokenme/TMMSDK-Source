//
//  UIApplication+TMMHook.m
//  TMMSDK
//
//  Created by Syd on 2018/7/27.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//
#import <objc/runtime.h>
#import "UIApplication+TMMHook.h"
#import "TMMHookHelper.h"

@implementation UIApplication (TMMHook)

+ (void)hookUIApplication
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method controlMethod = class_getInstanceMethod([UIApplication class], @selector(sendAction:to:from:forEvent:));
        Method hookMethod = class_getInstanceMethod([self class], @selector(hook_sendAction:to:from:forEvent:));
        method_exchangeImplementations(controlMethod, hookMethod);
    });
}


- (BOOL)hook_sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event;
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": NSStringFromClass([target class]), @"action":NSStringFromSelector(action)}];
    });
    return [self hook_sendAction:action to:target from:sender forEvent:event];
}

@end
