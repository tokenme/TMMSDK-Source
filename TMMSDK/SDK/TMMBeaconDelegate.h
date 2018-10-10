//
//  TMMBeaconDelegate.h
//  TMMSDK
//
//  Created by Syd on 2018/7/30.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TMMBeaconDelegate <NSObject>
- (void)hookNotification:(NSNotification *)info;
@end
