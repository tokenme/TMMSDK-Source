// TMMAFNetworkReachabilityManager.m
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TMMAFNetworkReachabilityManager.h"
#if !TARGET_OS_WATCH

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const TMMAFNetworkingReachabilityDidChangeNotification = @"io.tokenmama.networking.reachability.change";
NSString * const TMMAFNetworkingReachabilityNotificationStatusItem = @"TMMAFNetworkingReachabilityNotificationStatusItem";

typedef void (^TMMAFNetworkReachabilityStatusBlock)(TMMAFNetworkReachabilityStatus status);

NSString * TMMAFStringFromNetworkReachabilityStatus(TMMAFNetworkReachabilityStatus status) {
    switch (status) {
        case TMMAFNetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"TMMAFNetworking", nil);
        case TMMAFNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"TMMAFNetworking", nil);
        case TMMAFNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"TMMAFNetworking", nil);
        case TMMAFNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"TMMAFNetworking", nil);
    }
}

static TMMAFNetworkReachabilityStatus TMMAFNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));

    TMMAFNetworkReachabilityStatus status = TMMAFNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = TMMAFNetworkReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = TMMAFNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = TMMAFNetworkReachabilityStatusReachableViaWiFi;
    }

    return status;
}

/**
 * Queue a status change notification for the main thread.
 *
 * This is done to ensure that the notifications are received in the same order
 * as they are sent. If notifications are sent directly, it is possible that
 * a queued notification (for an earlier status condition) is processed after
 * the later update, resulting in the listener being left in the wrong state.
 */
static void TMMAFPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, TMMAFNetworkReachabilityStatusBlock block) {
    TMMAFNetworkReachabilityStatus status = TMMAFNetworkReachabilityStatusForFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(status);
        }
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ TMMAFNetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:TMMAFNetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}

static void TMMAFNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    TMMAFPostReachabilityStatusChange(flags, (__bridge TMMAFNetworkReachabilityStatusBlock)info);
}


static const void * TMMAFNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void TMMAFNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface TMMAFNetworkReachabilityManager ()
@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) TMMAFNetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) TMMAFNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@end

@implementation TMMAFNetworkReachabilityManager

+ (instancetype)sharedManager {
    static TMMAFNetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self manager];
    });

    return _sharedManager;
}

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);

    TMMAFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);

    return manager;
}

+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    TMMAFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];

    CFRelease(reachability);
    
    return manager;
}

+ (instancetype)manager
{
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self managerForAddress:&address];
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }

    _networkReachability = CFRetain(reachability);
    self.networkReachabilityStatus = TMMAFNetworkReachabilityStatusUnknown;

    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"`-init` unavailable. Use `-initWithReachability:` instead"
                                 userInfo:nil];
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}

#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == TMMAFNetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == TMMAFNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    [self stopMonitoring];

    if (!self.networkReachability) {
        return;
    }

    __weak __typeof(self)weakSelf = self;
    TMMAFNetworkReachabilityStatusBlock callback = ^(TMMAFNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }

    };

    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, TMMAFNetworkReachabilityRetainCallback, TMMAFNetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, TMMAFNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            TMMAFPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }

    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString {
    return TMMAFStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(TMMAFNetworkReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }

    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
#endif
