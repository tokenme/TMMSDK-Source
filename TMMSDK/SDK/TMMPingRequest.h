//
//  TMMPingRequest.h
//  TMMSDK
//
//  Created by Syd on 2018/8/1.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#ifndef TMMPingRequest_h
#define TMMPingRequest_h
#import "TMMJSONModelLib.h"

@class TMMDevice;

@interface TMMPingRequest: TMMJSONModel
@property(nonatomic,strong) NSString* logs;
@property(nonatomic,assign) NSUInteger duration;
@property(nonatomic,strong) TMMDevice* device;

- (id) initWithDuration:(NSUInteger) duration
                 device:(TMMDevice *) device
                   logs:(NSArray *)logs;
@end

#endif /* TMMPingRequest_h */
