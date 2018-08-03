//
//  UIScrollView+TMMHook.m
//  TMMSDK
//
//  Created by Syd on 2018/7/27.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <objc/runtime.h>
#import "UIScrollView+TMMHook.h"
#import "TMMHookHelper.h"

@implementation UIScrollView (TMMHook)

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
        //    NSLog(@"******** 没有实现 (%@) 方法，手动添加成功！！",NSStringFromSelector(originalSel));
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

+ (void)hookUIScrollView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method delegateMethod = class_getInstanceMethod([UIScrollView class], @selector(setDelegate:));
        Method hookMethod = class_getInstanceMethod([UIScrollView class], @selector(hook_setDelegate:));
        method_exchangeImplementations(delegateMethod, hookMethod);
    });
}

- (void)hook_setDelegate:(id<UIScrollViewDelegate>)delegate {
    [self hook_setDelegate:delegate];
    
    if ([self isMemberOfClass:[UIScrollView class]]) {
        //NSLog(@"是UIScrollView，hook方法");
        //Hook (scrollViewWillBeginDragging:) 方法
        Hook_Method([delegate class], @selector(scrollViewWillBeginDragging:), [self class], @selector(p_scrollViewWillBeginDragging:), @selector(add_scrollViewWillBeginDragging:));
        
        //Hook (scrollViewDidEndDecelerating:) 方法
        Hook_Method([delegate class], @selector(scrollViewDidEndDecelerating:), [self class], @selector(p_scrollViewDidEndDecelerating:), @selector(add_scrollViewDidEndDecelerating:));
        
        //Hook (scrollViewDidEndDragging:willDecelerate:) 方法
        Hook_Method([delegate class], @selector(scrollViewDidEndDragging:willDecelerate:), [self class], @selector(p_scrollViewDidEndDragging:willDecelerate:), @selector(add_scrollViewDidEndDragging:willDecelerate:));
    } else {
        //NSLog(@"不是UIScrollView，不需要hook方法");
    }
}

// 已经实现需要hook的代理方法时，调用此处方法进行替换
#pragma mark - Replace_Method
- (void)p_scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //NSLog(@"%s", __func__);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": NSStringFromClass([self class]), @"action": @"scrollViewWillBeginDragging" }];
    });
    [self p_scrollViewWillBeginDragging:scrollView];
}

- (void)p_scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //NSLog(@"%s", __func__);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": NSStringFromClass([self class]), @"action": @"scrollViewDidEndDecelerating" }];
    });
    [self p_scrollViewDidEndDecelerating:scrollView];
    // 停止类型1、停止类型2
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [scrollView stopScroll:scrollView];
    }
}

- (void)p_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //NSLog(@"%s", __func__);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": NSStringFromClass([self class]), @"action": @"scrollViewDidEndDragging" }];
    });
    [self p_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if (!decelerate) {
        // 停止类型3
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [scrollView stopScroll:scrollView];
        }
    }
}

// 那没有实现需要hook的代理方法时，调用此处方法
#pragma mark - Add_Method
- (void)add_scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //NSLog(@"%s", __func__);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": NSStringFromClass([self class]), @"action": @"scrollViewWillBeginDragging" }];
    });
}

- (void)add_scrollViewWillDecelerating:(UIScrollView *)scrollView {
    //NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": NSStringFromClass([self class]), @"action": @"scrollViewDidEndDecelerating" }];
}

- (void)add_scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //NSLog(@"%s", __func__);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TMMHookNotificationName object:nil userInfo:@{@"class": NSStringFromClass([self class]), @"action": @"scrollViewDidEndDragging" }];
    });
    // 停止类型1、停止类型2
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [scrollView stopScroll:scrollView];
    }
}

- (void)add_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //NSLog(@"%s", __func__);
    if (!decelerate) {
        // 停止类型3
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [scrollView stopScroll:scrollView];
        }
    }
}

#pragma mark - scrollView 滚动停止时触发的方法
- (void)stopScroll:(UIScrollView *)scrollView {
    //NSLog(@"滚动已停止");
}

@end
