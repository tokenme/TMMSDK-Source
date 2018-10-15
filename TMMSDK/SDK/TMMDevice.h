//
//  TMMDevice.h
//  TMMSDK
//
//  Created by Syd on 2018/7/30.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMJSONModelLib.h"

@interface TMMDevice: TMMJSONModel

@property(nonatomic,assign) BOOL isEmulator;
@property(nonatomic,assign) BOOL isTablet;
@property(nonatomic,assign) BOOL isJailBrojen;
@property(nonatomic,strong) NSString *deviceName;
@property(nonatomic,strong) NSString *carrier;
@property(nonatomic,strong) NSString *country;
@property(nonatomic,strong) NSString *timezone;
@property(nonatomic,strong) NSString *systemVersion;
@property(nonatomic,strong) NSString *appName;
@property(nonatomic,strong) NSString *appVersion;
@property(nonatomic,strong) NSString *appBundleID;
@property(nonatomic,strong) NSString *appBuildVersion;
@property(nonatomic,strong) NSString *ip;
@property(nonatomic,strong) NSString *language;
@property(nonatomic,strong) NSString *idfa;
@property(nonatomic,strong) NSString *deviceType;
@property(nonatomic,strong) NSString *osVersion;
@property(nonatomic,strong) NSString *platform;

- (id) init;
@end
