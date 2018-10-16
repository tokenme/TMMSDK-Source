//
//  TMMBeacon.m
//  TMMBeacon
//
//  Created by Syd on 2018/7/27.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TMMBeaconDelegate.h"
#import "TMMBeacon.h"
#import "TMMWeakTimer.h"
#import "TMMHook.h"
#import "TMMDevice.h"
#import "TMMPingRequest.h"
#import "TMMApi.h"
#import "NSString+Encryption.h"
#import "UIView+Toast.h"

NSString * TMMToastPositionTop                       = @"CSToastPositionTop";
NSString * TMMToastPositionCenter                    = @"CSToastPositionCenter";
NSString * TMMToastPositionBottom                    = @"CSToastPositionBottom";

static const char *TMMTimerQueueContext = "TMMTimerQueueContext";
static const char *TMMNotificationQueueContext = "TMMNotificationQueueContext";
static const char *TMMTimerQueueName = "io.tokenmama.private_queue";
static const char *TMMNotificationQueueName = "io.tokenmama.notification_queue";
static const NSTimeInterval TMMDefaultHeartBeatInterval = 60;
static const NSTimeInterval TMMDefaultNotificationInterval = 120;
static const NSTimeInterval TMMDefaultToastDuration = 3.0;
static const NSUInteger TMMDefaultMaxLogs = 100;

@interface TMMBeacon() <TMMBeaconDelegate>
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;

@property (nonatomic, assign) NSTimeInterval heartBeatInterval;
@property (nonatomic, assign) NSTimeInterval notificationInterval;
    
@property (strong, nonatomic) TMMWeakTimer *backgroundTimer;
@property (strong, nonatomic) dispatch_queue_t privateQueue;
    
@property (strong, nonatomic) TMMWeakTimer *notificationTimer;
@property (strong, nonatomic) dispatch_queue_t notificationQueue;
    
@property (strong, nonatomic) TMMHook *hook;

@property (nonatomic, assign) NSUInteger latestActiveTS;
@property (nonatomic, assign) NSUInteger duration;

@property (nonatomic, strong) TMMDevice *device;
    
@property (nonatomic, strong) NSMutableArray *logs;
    
@property (nonatomic, assign) BOOL notificationEnabled;

@property (nonatomic, strong) CSToastStyle *toastStyle;

@property (nonatomic, strong) NSString *toastPosition;

@property (nonatomic, assign) NSTimeInterval toastDuration;

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
    _instance.hook = [TMMHook initWithDelegate:_instance];
    _instance.logs = [[NSMutableArray alloc] initWithCapacity:1024];
    [_instance setHeartBeatInterval: TMMDefaultHeartBeatInterval];
    [_instance setNotificationInterval: TMMDefaultNotificationInterval];
    _instance.notificationEnabled = YES;
    _instance.toastPosition = [NSString stringWithString: TMMToastPositionTop];
    _instance.toastStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    _instance.toastStyle.backgroundColor = [[UIColor alloc] initWithWhite:0.93 alpha:0.75];
    _instance.toastStyle.shadowOpacity = 0.6;
    _instance.toastStyle.shadowOffset = CGSizeMake(0.0, 2.0);
    _instance.toastStyle.shadowRadius = 4.0;
    _instance.toastStyle.titleColor = UIColor.blackColor;
    _instance.toastStyle.messageColor = UIColor.darkTextColor;
    _instance.toastStyle.displayShadow = YES;
    _instance.toastStyle.imageSize = CGSizeMake(40.0, 40.0);
    [CSToastManager setSharedStyle:_instance.toastStyle];
    [CSToastManager setTapToDismissEnabled:YES];
    [_instance setToastDuration:TMMDefaultToastDuration];
    [CSToastManager setQueueEnabled:YES];
    return _instance ;
}

- (void)dealloc {
    [_backgroundTimer invalidate];
}

- (void) start {
    NSLog(@"TMMBeacon Start!");
    [self saveDevice];
}

- (void) stop {
    NSLog(@"TMMBeacon Stopped!");
    [_backgroundTimer invalidate];
}
    
- (void) disableNotification {
    NSLog(@"TMMBeacon Notification Disabled!");
    _notificationEnabled = NO;
    [_notificationTimer invalidate];
}

- (void) setToastPosition:(NSString *)toastPosition {
    _toastPosition = toastPosition;
}

- (void) setToastBackgroundColor: (UIColor *) color {
    _toastStyle.backgroundColor = color;
}

- (void) setToastTitleColor: (UIColor *) color {
    _toastStyle.titleColor = color;
}

- (void) setToastMessageColor: (UIColor *) color {
    _toastStyle.messageColor = color;
}

- (void) setToastDuration:(NSTimeInterval)duration {
    [CSToastManager setDefaultDuration:duration];
    _toastDuration = duration;
}

- (NSString *) deviceId {
    return self.device.idfa;
}

- (NSDictionary *) deviceInfo {
    return [self.device toDictionary];
}

- (void) setHeartBeatInterval:(NSTimeInterval)heartBeatInterval {
    _heartBeatInterval = heartBeatInterval;
}
    
- (void) setNotificationInterval:(NSTimeInterval)notificationInterval {
    _notificationInterval = notificationInterval;
}
    
- (void)startHeartBeat:(NSTimeInterval)time{
    self.privateQueue = dispatch_queue_create(TMMTimerQueueName, DISPATCH_QUEUE_CONCURRENT);
    
    self.backgroundTimer = [TMMWeakTimer scheduledTimerWithTimeInterval:time
                                                                target:self
                                                              selector:@selector(heartbeatSend)
                                                              userInfo:nil
                                                               repeats:YES
                                                         dispatchQueue:self.privateQueue];
    
    dispatch_queue_set_specific(self.privateQueue, (__bridge const void *)(self), (void *)TMMTimerQueueContext, NULL);
}

- (void)startNotification:(NSTimeInterval)time{
    self.notificationQueue = dispatch_queue_create(TMMNotificationQueueName, DISPATCH_QUEUE_CONCURRENT);
    
    self.notificationTimer = [TMMWeakTimer scheduledTimerWithTimeInterval:time
                                                                target:self
                                                              selector:@selector(getDevicePoints)
                                                              userInfo:nil
                                                               repeats:YES
                                                         dispatchQueue:self.notificationQueue];
    
    dispatch_queue_set_specific(self.notificationQueue, (__bridge const void *)(self), (void *)TMMNotificationQueueContext, NULL);
}

- (void)debugToast {
    NSString *alertTitle = I18n(@"TBCAlertTitle", "alert title");
    NSString *alertMessage = [NSString stringWithFormat:I18n(@"TBCAlertMessage", "alert message"), "0.12"];
    UIImage *alertImage = [UIImage imageNamed:@"Logo" inBundle:TMMSDKBundle compatibleWithTraitCollection:nil];
    [self showToastWithTitle:alertTitle
                 description:alertMessage
                       image:alertImage
                    imageURL:nil
                        link:@"https://tmm.tokenmama.io/app/ios"];
}

- (void)heartbeatSend{
    __weak __typeof(self) weakSelf = self;
    NSUInteger du = _duration;
    if (du == 0) {
        return;
    }
    if (_device.isEmulator || _device.isJailBrojen) {
        return;
    }
    TMMPingRequest * pingReq = [[TMMPingRequest alloc] initWithDuration:du device:_device logs:_logs];
    NSString *payload = [pingReq.toJSONString desEncryptWithKey: _appSecret];
    [TMMApi callMethod:@"device/ping"
               payload:payload
                   key:_appKey
                secret:_appSecret
               success:^(NSURLSessionDataTask *task, id responseObject) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       if (!weakSelf) return;
                       __strong typeof(self) strongSelf = weakSelf;
                       strongSelf.duration = 0;
                       [strongSelf.logs removeAllObjects];
                   });
               }
               failure:nil
     ];
    
    return;
}

- (void)saveDevice {
    __weak __typeof(self) weakSelf = self;
    NSString *payload = [_device.toJSONString desEncryptWithKey:_appSecret];
    [TMMApi callMethod:@"device/save"
               payload:payload
                   key:_appKey
                secret:_appSecret
               success:^(NSURLSessionDataTask *task, id responseObject) {
                   if (!weakSelf) return;
                   __strong typeof(self) strongSelf = weakSelf;
                   [strongSelf startHeartBeat: strongSelf.heartBeatInterval];
                   [strongSelf startNotification: strongSelf.notificationInterval];
               }
               failure:nil
     ];
}

- (void)getDevicePoints {
    __weak __typeof(self) weakSelf = self;
    if (!_notificationEnabled) {
        return;
    }
    NSString *payload = [_device.toJSONString desEncryptWithKey:_appSecret];
    [TMMApi callMethod:@"device/points"
               payload:payload
                   key:_appKey
                secret:_appSecret
               success:^(NSURLSessionDataTask *task, id responseObject) {
                   if (!weakSelf) return;
                   __strong typeof(self) strongSelf = weakSelf;
                   if (responseObject) {
                       if (responseObject[@"title"] != [NSNull null] && [responseObject[@"title"] isKindOfClass:[NSString class]]) {
                           NSString *alertTitle = [NSString stringWithString:responseObject[@"title"]];
                           NSString *alertMessage = [[NSString alloc] init];
                           NSString *link = [[NSString alloc] init];
                           NSString *imageLink = [[NSString alloc] init];
                           if (responseObject[@"desc"] != [NSNull null] && [responseObject[@"desc"] isKindOfClass:[NSString class]]) {
                               alertMessage = [NSString stringWithString:responseObject[@"desc"]];
                           }
                           if (responseObject[@"link"] != [NSNull null] && [responseObject[@"link"] isKindOfClass:[NSString class]]) {
                               link = [NSString stringWithString:responseObject[@"link"]];
                           }
                           if (responseObject[@"icon"] != [NSNull null] && [responseObject[@"icon"] isKindOfClass:[NSString class]]) {
                               imageLink = [NSString stringWithString:responseObject[@"icon"]];
                           }
                           NSURL *imageURL = [NSURL URLWithString:imageLink];
                           [strongSelf showToastWithTitle:alertTitle description:alertMessage image:nil imageURL:imageURL link:link];
                       }
                   }
               }
               failure:nil
     ];
}

- (void) showToastWithTitle:(NSString *)title description:(NSString *)desc image:(UIImage *)image imageURL:(NSURL *)imageURL link:(NSString *) link  {
    __weak __typeof(self) weakSelf = self;
    if (image == nil && imageURL == nil) {
        image = [UIImage imageNamed:@"Logo" inBundle:TMMSDKBundle compatibleWithTraitCollection:nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf) return;
        __strong typeof(self) strongSelf = weakSelf;
        UIViewController *vc = [strongSelf rootViewController];
        [vc.view makeToast: desc
                  duration: strongSelf.toastDuration
                  position: CSToastPositionTop
                     title: title
                     image: image
                  imageURL: imageURL
                     style: nil
                completion:^(BOOL didTap) {
                    if (didTap && link != nil) {
                        NSURL *url = [NSURL URLWithString:link];
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }];
    });
}
                   
- (UIViewController *) rootViewController {
    UIWindow *windowW = [UIApplication sharedApplication].keyWindow;
    return windowW.rootViewController;
}

# pragma mark - hookNotification delegate
- (void)hookNotification: (NSNotification *)info {
    NSUInteger ts = [[NSDate date] timeIntervalSince1970];
    NSUInteger interval = ts - _latestActiveTS;
    _latestActiveTS = ts;
    if (interval >= 60) {
        return;
    }
    _duration += interval;
    
    [_logs addObject:info.userInfo];
    if ([_logs count] >= TMMDefaultMaxLogs) {
        [_logs removeObjectAtIndex:0];
    }
    //NSLog(@"logs:%@", _logs);
}

@end


