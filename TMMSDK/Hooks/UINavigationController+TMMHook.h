//
//  UINavigationController+TMMHook.h
//  TMMSDK
//
//  Created by Syd on 2018/7/27.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UINavigationController (TMMHook)
+ (void)hookUINavigationController_push;
+ (void)hookUINavigationController_pop;
@end
