//
//  TMMPingRequest.h
//  TMMSDK
//
//  Created by Syd on 2018/8/1.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#ifndef TMMPingRequest_h
#define TMMPingRequest_h
#import "JSONModelLib.h"

@class TMMDevice;

@interface TMMPingRequest: JSONModel
@property(nonatomic,assign) NSUInteger duration;
@property(nonatomic,strong) TMMDevice* device;

- (id) initWithDuration:(NSUInteger) duration
                           device:(TMMDevice *) device;
@end

#endif /* TMMPingRequest_h */
