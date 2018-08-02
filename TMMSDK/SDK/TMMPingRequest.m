//
//  TMMPingRequest.m
//  TMMSDK
//
//  Created by Syd on 2018/8/1.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMPingRequest.h"

@implementation TMMPingRequest

- (id) initWithDuration:(NSUInteger) duration
                           device:(TMMDevice *) device {
    self = [super init];
    if (self) {
        self.duration = duration;
        self.device = device;
    }
    return self;
}

@end
