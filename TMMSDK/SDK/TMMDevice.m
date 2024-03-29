//
//  TMMDevice.m
//  TMMSDK
//
//  Created by Syd on 2018/7/30.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import "TMMDevice.h"
#import "TMMDeviceInfo.h"

@implementation TMMDevice

- (id) init {
    self = [super init];
    if (self) {
        self.isEmulator = [TMMDeviceInfo isEmulator];
        self.isTablet = [TMMDeviceInfo isTablet];
        self.isJailBrojen = [TMMDeviceInfo isJailBrojen];
        self.platform = @"ios";
        self.deviceName = [TMMDeviceInfo getDeviceName];
        self.carrier = [TMMDeviceInfo getCarrier];
        self.country = [TMMDeviceInfo getDeviceCountry];
        self.timezone = [TMMDeviceInfo getTimezone];
        self.systemVersion = [TMMDeviceInfo getSystemVersion];
        self.appName = [TMMDeviceInfo getApplicationName];
        self.appVersion = [TMMDeviceInfo getAppVersion];
        self.appBundleID = [TMMDeviceInfo getBundleID];
        self.appBuildVersion = [TMMDeviceInfo getBuildVersion];
        self.ip = [TMMDeviceInfo getDeviceIPAdress];
        self.language = [TMMDeviceInfo getDeviceLanguage];
        self.deviceType = [TMMDeviceInfo deviceTypeDetail];
        self.osVersion = [TMMDeviceInfo getOSVersion];
        self.idfa = [TMMDeviceInfo IDFA];
    }
    return self;
}

@end
