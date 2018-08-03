//
//  UIWebView+TMMHook.m
//  TMMSDK
//
//  Created by Syd on 2018/7/27.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <objc/runtime.h>
#import "UIWebView+TMMHook.h"
#import "TMMHookHelper.h"

@implementation UIWebView (TMMHook)

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

+ (void)hookUIWebView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method delegateMethod = class_getInstanceMethod([UIWebView class], @selector(setDelegate:));
        Method hookMethod = class_getInstanceMethod([UIWebView class], @selector(hook_setDelegate:));
        method_exchangeImplementations(delegateMethod, hookMethod);
    });
}

- (void)hook_setDelegate:(id<UIWebViewDelegate>)delegate {
    
    [self hook_setDelegate:delegate];
    
    //Hook (webViewDidStartLoad:) 方法
    Hook_Method([delegate class], @selector(webViewDidStartLoad:), [self class], @selector(owner_webViewDidStartLoad:), @selector(none_webViewDidStartLoad:));
    
    //Hook (webViewDidFinishLoad:) 方法
    Hook_Method([delegate class], @selector(webViewDidFinishLoad:), [self class], @selector(owner_webViewDidFinishLoad:), @selector(none_webViewDidFinishLoad:));
}

- (void)owner_webViewDidStartLoad:(UIWebView *)webView {
    
    //NSLog(@"*********** owner_webViewDidStartLoad:");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": @"webView", @"action":@"webViewDidStartLoad"}];
    });
    [self owner_webViewDidStartLoad:webView];
    
}

- (void)none_webViewDidStartLoad:(UIWebView *)webView {
    //NSLog(@"*********** none_webViewDidStartLoad:");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": @"webView", @"action":@"webViewDidStartLoad"}];
    });
}


- (void)owner_webViewDidFinishLoad:(UIWebView *)webView {
    
    //NSLog(@"*********** owner_webViewDidFinishLoad:");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": @"webView", @"action":@"webViewDidFinishLoad"}];
    });
    [self owner_webViewDidFinishLoad:webView];
    
}

- (void)none_webViewDidFinishLoad:(UIWebView *)webView {
    //NSLog(@"*********** none_webViewDidFinishLoad:");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": @"webView", @"action":@"webViewDidFinishLoad"}];
    });
}

@end
