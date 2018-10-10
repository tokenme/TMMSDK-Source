//
//  TMMPingRequest.m
//  TMMSDK
//
//  Created by Syd on 2018/8/1.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMPingRequest.h"
#import "NSString+Hashes.h"

@implementation TMMPingRequest

- (id) initWithDuration:(NSUInteger) duration
                 device:(TMMDevice *) device
                   logs:(NSArray *)logs {
    self = [super init];
    if (self) {
        self.duration = duration;
        self.device = device;
        if ([NSJSONSerialization isValidJSONObject:logs]) {
            if (@available(iOS 11.0, *)) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:logs options:NSJSONWritingSortedKeys error:nil];
                NSString *jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                self.logs = jsonString;
            }
            
        }
    }
    return self;
}

@end
