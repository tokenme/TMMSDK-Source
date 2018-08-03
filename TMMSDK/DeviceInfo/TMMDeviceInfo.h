//
//  TMMDeviceInfo.h
//  TMM-SDK
//
//  Created by Syd on 2018/7/26.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#ifndef TMMDeviceInfo_h
#define TMMDeviceInfo_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TMMDeviceInfo : NSObject
    
    // 返回本类提供的所有设备信息
+ (NSDictionary *)deviceInfo;
    
    /**
     executablePath 和 其进行MD5加密后的值
     executablePath = array[0];
     MD5Value = array[1];
     
     @return executablePath和其MD5值加密值
     */
+ (NSArray *)executablePathAndMD5Value;
    /**
     是否是模拟器
     @return Bool
    */
    
+ (BOOL) isEmulator;
+ (BOOL) isTablet;
    /**
     是否越狱
     @return 是否越狱
     */
+ (BOOL)isJailBrojen;
+ (NSString*) getOSVersion;
+ (NSString*) deviceTypeDetail;

    /**
     Gets the carrier name (network operator).
     @return String
     */
+ (NSString *) getCarrier;
+ (NSString *) getDeviceCountry;
+ (NSString*) getTimezone;
+ (NSString *) getSystemVersion;
+ (NSString *) getUserAgent;
    /**
     获取设备Mac地址
     @return Mac地址
     */
+ (NSString *)getMacAddress;
    //- (NSString*)getMainBundleMD5WithFlag:(NSInteger)flag;
    
    
    /**
     获取App名称
     @return app名称
     */
+ (NSString *)getApplicationName;
    
    /**
     获取app版本号
     @return app版本号
     */
+ (NSString *) getAppVersion;
    
    /**
     获取BundleID
     @return bundle ID
     */
+ (NSString*) getBundleID;
+ (NSString *) getBuildVersion;

    
    /**
     获取设备当前IP
     @return  获取设备当前IP
     */
+ (NSString *)getDeviceIPAdress;
    
    /**
     电池电量
     @return 电池电量
     */
+ (CGFloat)getBatteryLevel;
    
    
    /**
     电池状态
     @return 电池状态
     */
+ (NSString *) getBatteryState;
    
    /**
     当期设备语言
     @return 当前设备语言
     */
+ (NSString *)getDeviceLanguage;

    //获取IDFA
+ (NSString*)IDFA;
    
    //删除keychain的IDFA(一般不需要)
+ (void)deleteIDFA;
    
@end


#endif /* TMMDeviceInfo_h */
