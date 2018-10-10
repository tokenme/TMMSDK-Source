//
//  TMMHook.m
//  TMMSDK
//
//  Created by Syd on 2018/7/30.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMHook.h"
#import "AppDelegate+TMMHook.h"
#import "UIApplication+TMMHook.h"
#import "UIViewController+TMMHook.h"
#import "UINavigationController+TMMHook.h"
#import "UITabBarController+TMMHook.h"
#import "UIScrollView+TMMHook.h"
#import "UIWebView+TMMHook.h"
#import "TMMHookHelper.h"
#import "TMMBeaconDelegate.h"

@interface TMMHook()
@property (nonatomic, weak) id observe;
@property (nonatomic, weak) id<TMMBeaconDelegate> delegate;
@end

@implementation TMMHook
static TMMHook* _instance = nil;

+(instancetype) shareInstance {
    return _instance;
}

+(instancetype) initWithDelegate:(id)delegate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
        [[NSNotificationCenter defaultCenter] addObserver:_instance selector:@selector(notify:) name:TMMHookNotificationName object:nil];
        [AppDelegateTMMHook hookAppDelegate];
        //[UIApplication hookUIApplication];
        [UIViewController hookUIViewController];
        [UINavigationController hookUINavigationController_pop];
        [UINavigationController hookUINavigationController_push];
        [UITabBarController hookUITabBarController];
        [UIScrollView hookUIScrollView];
        [UIWebView hookUIWebView];
    });
    _instance.delegate = delegate;
    return _instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notify:(NSNotification *) userInfo {
    if (_delegate != nil) {
        [_delegate hookNotification: userInfo];
    }
}
    
@end
