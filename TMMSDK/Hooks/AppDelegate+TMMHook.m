//
//  AppDelegate+TMMHook.m
//  TMMSDK
//
//  Created by Syd on 2018/7/27.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <objc/runtime.h>
#import "AppDelegate+TMMHook.h"
#import "TMMHookHelper.h"

@implementation AppDelegateTMMHook

static void Hook_Method(Class originalClass, SEL originalSel, Class replacedClass, SEL replacedSel, SEL noneSel) {
    // 原实例方法
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    // 替换的实例方法
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    // 如果没有实现 delegate 方法，则手动动态添加
    if (!originalMethod) {
        Method noneMethod = class_getInstanceMethod(replacedClass, noneSel);
        BOOL didAddNoneMethod = class_addMethod(originalClass, originalSel, method_getImplementation(noneMethod), method_getTypeEncoding(noneMethod));
        if (didAddNoneMethod) {
            //NSLog(@"******** 没有实现 (%@) 方法，手动添加成功！！",NSStringFromSelector(originalSel));
        }
        return;
    }
    // 向实现 delegate 的类中添加新的方法
    // 这里是向 originalClass 的 replaceSel（@selector(owner_webViewDidStartLoad:)） 添加 replaceMethod
    BOOL didAddMethod = class_addMethod(originalClass, replacedSel, method_getImplementation(replacedMethod), method_getTypeEncoding(replacedMethod));
    if (didAddMethod) {
        // 添加成功
        //NSLog(@"******** 实现了 (%@) 方法并成功 Hook 为 --> (%@)",NSStringFromSelector(originalSel) ,NSStringFromSelector(replacedSel));
        // 重新拿到添加被添加的 method,这里是关键(注意这里 originalClass, 不 replacedClass), 因为替换的方法已经添加到原类中了, 应该交换原类中的两个方法
        Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
        // 实现交换
        method_exchangeImplementations(originalMethod, newMethod);
    }else{
        // 添加失败，则说明已经 hook 过该类的 delegate 方法，防止多次交换。
        //NSLog(@"******** 已替换过，避免多次替换 --> (%@)",NSStringFromClass(originalClass));
    }
}

+(void) hookAppDelegate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Hook_Method([[UIApplication sharedApplication].delegate class], @selector(application:didFinishLaunchingWithOptions:), [self class], @selector(hook_application:didFinishLaunchingWithOptions:), @selector(none_application:didFinishLaunchingWithOptions:));
        
        Hook_Method([[UIApplication sharedApplication].delegate class], @selector(application:handleOpenURL:), [self class], @selector(hook_application:handleOpenURL:), @selector(none_application:handleOpenURL:));
        
        Hook_Method([[UIApplication sharedApplication].delegate class], @selector(application:openURL:sourceApplication:annotation:), [self class], @selector(hook_application:openURL:sourceApplication:annotation:), @selector(none_application:openURL:sourceApplication:annotation:));
        
        Hook_Method([[UIApplication sharedApplication].delegate class], @selector(application:openURL:sourceApplication:annotation:), [self class], @selector(hook_application:openURL:sourceApplication:annotation:), @selector(none_application:openURL:sourceApplication:annotation:));
        
        Hook_Method([[UIApplication sharedApplication].delegate class], @selector(application:supportedInterfaceOrientationsForWindow:), [self class], @selector(hook_application:supportedInterfaceOrientationsForWindow:), @selector(none_application:supportedInterfaceOrientationsForWindow:));
        
        Hook_Method([[UIApplication sharedApplication].delegate class], @selector(applicationDidBecomeActive:), [self class], @selector(hook_applicationDidBecomeActive:), @selector(none_applicationDidBecomeActive:));
        
        Hook_Method([[UIApplication sharedApplication].delegate class], @selector(applicationDidEnterBackground:), [self class], @selector(hook_applicationDidEnterBackground:), @selector(none_applicationDidEnterBackground:));
        
        Hook_Method([[UIApplication sharedApplication].delegate class], @selector(applicationWillEnterForeground:), [self class], @selector(hook_applicationWillEnterForeground:), @selector(none_applicationWillEnterForeground:));
        
        Hook_Method([[UIApplication sharedApplication].delegate class], @selector(application:didReceiveLocalNotification:), [self class], @selector(hook_application:didReceiveLocalNotification:), @selector(none_application:didReceiveLocalNotification:));
        
        Hook_Method([[UIApplication sharedApplication].delegate class], @selector(application:didFinishLaunchingWithOptions:), [self class], @selector(hook_application:didFinishLaunchingWithOptions:), @selector(none_application:didFinishLaunchingWithOptions:));
    });
}

-(BOOL)hook_application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [self hook_application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

-(BOOL)none_application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    
    //NSLog(@"none didFinishLaunchingWithOptions");
    return YES;
}

- (BOOL)hook_application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    //NSLog(@"hooked handleOpenURL");
    [self hook_application:application handleOpenURL:url];
    return YES;
}

- (BOOL)none_application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    //NSLog(@"none handleOpenURL");
    return YES;
}

- (BOOL)hook_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //NSLog(@"hooked openURL sourceApplication annotation");
    [self hook_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return YES;
}

- (BOOL)none_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //NSLog(@"none openURL sourceApplication annotation");
    return YES;
}

- (NSUInteger) hook_application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    //NSLog(@"hooked supportedInterfaceOrientationsForWindow");
    [self hook_application:application supportedInterfaceOrientationsForWindow:window ];
    return 0;
}

- (NSUInteger) none_application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    //NSLog(@"none supportedInterfaceOrientationsForWindow");
    return 0;
}

- (void)hook_applicationDidBecomeActive:(UIApplication *)application
{
    [self hook_applicationDidBecomeActive:application];
    //NSLog(@"hooked applicationDidBecomeActive");
}

- (void)none_applicationDidBecomeActive:(UIApplication *)application
{
    //NSLog(@"hooked applicationDidBecomeActive");
}

- (void)hook_applicationDidEnterBackground:(UIApplication *)application
{
    [self hook_applicationDidEnterBackground:application];
    //NSLog(@"hooked applicationDidEnterBackground");
}

- (void)none_applicationDidEnterBackground:(UIApplication *)application
{
    //NSLog(@"hooked applicationDidEnterBackground");
}

- (void)hook_applicationWillEnterForeground:(UIApplication *)application
{
    [self hook_applicationWillEnterForeground:application];
    //NSLog(@"hooked applicationDidEnterBackground");
}

- (void)none_applicationWillEnterForeground:(UIApplication *)application
{
    //NSLog(@"hooked applicationDidEnterBackground");
}
    
- (void)hook_application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*) notification
{
    [self hook_application:application didReceiveLocalNotification:notification];
    //NSLog(@"hooked application:didReceiveLocalNotification:");
}
    
- (void)none_application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*) notification
{
    //NSLog(@"hooked application:didReceiveLocalNotification:");
}

@end
