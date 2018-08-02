//
//  TMMBeacon.m
//  TMMBeacon
//
//  Created by Syd on 2018/7/27.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMBeaconDelegate.h"
#import "TMMBeacon.h"
#import "MSWeakTimer.h"
#import "TMMHook.h"
#import "TMMDevice.h"
#import "TMMPingRequest.h"
#import "TMMAES256.h"
#import "TMMApi.h"

static const char *TMMTimerQueueContext = "TMMTimerQueueContext";
static const char *TMMTimerQueueName = "io.tokenmama.private_queue";
static const NSTimeInterval DefaultHeartBeatInterval = 60;

@interface TMMBeacon() <TMMBeaconDelegate>
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;

@property (nonatomic, assign) NSTimeInterval heartBeatInterval;
@property (strong, nonatomic) MSWeakTimer *backgroundTimer;
@property (strong, nonatomic) dispatch_queue_t privateQueue;
@property (strong, nonatomic) TMMHook *hook;

@property (nonatomic, assign) NSUInteger latestActiveTS;
@property (nonatomic, assign) NSUInteger duration;

@property (nonatomic, strong) TMMDevice *device;

@end

@implementation TMMBeacon
    
static TMMBeacon* _instance = nil;
    
+(instancetype) shareInstance {
    return _instance;
}
    
+(instancetype) initWithKey:(NSString *)key secret:(NSString *)secret {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    _instance.appKey = key;
    _instance.appSecret = secret;
    _instance.device = [[TMMDevice alloc] init];
    _instance.hook = [TMMHook initWithDelegate:self];
    [_instance setHeartBeatInterval: DefaultHeartBeatInterval];
    return _instance ;
}

- (void)dealloc {
    [_backgroundTimer invalidate];
}

- (void) start {
    [self startHeartBeat: _heartBeatInterval];
}

- (void) stop {
    [_backgroundTimer invalidate];
}

- (void) setHeartBeatInterval:(NSTimeInterval)heartBeatInterval {
    _heartBeatInterval = heartBeatInterval;
}
    
- (void)startHeartBeat:(NSTimeInterval)time{
    self.privateQueue = dispatch_queue_create(TMMTimerQueueName, DISPATCH_QUEUE_CONCURRENT);
    
    self.backgroundTimer = [MSWeakTimer scheduledTimerWithTimeInterval:time
                                                                target:self
                                                              selector:@selector(heartbeatSend)
                                                              userInfo:nil
                                                               repeats:YES
                                                         dispatchQueue:self.privateQueue];
    
    dispatch_queue_set_specific(self.privateQueue, (__bridge const void *)(self), (void *)TMMTimerQueueContext, NULL);
}
    
- (void)heartbeatSend{
    NSLog(@"TMMHeartbeat");
    __weak __typeof(self) weakSelf = self;
    NSUInteger du = _duration;
    NSLog(@"%lu, %@", (unsigned long)du, _device.toJSONString);
    TMMPingRequest * pingReq = [[TMMPingRequest alloc] initWithDuration:du device:_device];
    [TMMApi callMethod:@"ping"
               payload:[TMMAES256 AES256Encrypt: _appSecret Encrypttext: pingReq.toJSONString]
                   key:_appKey
                secret:_appSecret
               success:^(NSURLSessionDataTask *task, id responseObject) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       if (!weakSelf) return;
                       __strong typeof(self) strongSelf = weakSelf;
                       strongSelf.duration = 0;
                   });
               }
               failure:nil
     ];
    
    return;
}

# pragma mark - hookNotification delegate
- (void)hookNotification {
    NSLog(@"hook notification");
    NSUInteger ts = [[NSDate date] timeIntervalSince1970];
    NSUInteger interval = ts - _latestActiveTS;
    _latestActiveTS = ts;
    if (interval >= 60) {
        return;
    }
    _duration += interval;
}

@end


