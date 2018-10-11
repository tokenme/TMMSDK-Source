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
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:logs options:0 error:&error];
            if (error != nil) {
                //NSLog(@"jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
            } else {
                NSString *jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                self.logs = jsonString;
                NSLog(@"logs: %@", jsonString);
            }
        } else {
            //NSLog(@"logs is invalid json object: %@", logs);
        }
    }
    return self;
}

@end
