//
//  TMMDeviceInfo.m
//  TMM-SDK
//
//  Created by Syd on 2018/7/26.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import "TMMDeviceInfo.h"
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import <ifaddrs.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "TMMKeyChainStore.h"

#define kIsStringValid(text) (text && text!=NULL && text.length>0)
NSString * const IDFA_SERVICE = @"io.tokenmama.sdk.idfa";
NSString * const IDFA_KEY = @"io.tokenmama.sdk.idfa.key";

@interface TMMDeviceInfo ()
@property (nonatomic, strong) NSMutableArray *array;
@end

#define IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhoneX (812 == [[UIScreen mainScreen] bounds].size.height ? YES : NO)

@interface TMMDeviceInfo()
    {
    }
    @property (retain, nonatomic)NSMutableArray *dirFileList;
    @end

@implementation TMMDeviceInfo
    //@synthesize dirFileList;
    
    static const char* jailbreak_apps[] =
    {
        "/Applications/Cydia.app",
        "/Applications/limera1n.app",
        "/Applications/greenpois0n.app",
        "/Applications/blackra1n.app",
        "/Applications/blacksn0w.app",
        "/Applications/redsn0w.app",
        "/Applications/Absinthe.app",
        NULL,
    };
    
+(NSString *)dataMD5:(NSString *)dataString
    {
        if(dataString == nil){
            return @"";
        }
        
#if(0)
        CC_MD5_CTX md5;
        CC_MD5_Init(&md5);
        NSData *fileAllData=[dataString dataUsingEncoding:NSUTF8StringEncoding];
        NSRange range;
        int i = 0;
        BOOL done=NO;
        while (!done) {
            range.location = i*1024;
            NSData *fileData;
            if(range.location+1024<=fileAllData.length){
                range.length = 1024;
                fileData=[fileAllData subdataWithRange:range];
            }
            else if(range.location+1<=fileAllData.length){
                range.length = fileAllData.length-range.location;
                fileData=[fileAllData subdataWithRange:range];
            }
            else{
                break;
            }
            
            CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
            if([fileData length]==0)
            done=YES;
            
            i++;
        }
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(digest, &md5);
        NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                       digest[0], digest[1],
                       digest[2], digest[3],
                       digest[4], digest[5],
                       digest[6], digest[7],
                       digest[8], digest[9],
                       digest[10], digest[11],
                       digest[12], digest[13],
                       digest[14], digest[15]];
        return s;
#endif
        
        const char *cStr = [dataString UTF8String];
        unsigned char result[16];
        CC_MD5( cStr, (unsigned int) strlen(cStr), result);
        NSString* s = [NSString stringWithFormat:
                       @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                       result[0], result[1], result[2], result[3],
                       result[4], result[5], result[6], result[7],
                       result[8], result[9], result[10], result[11],
                       result[12], result[13], result[14], result[15]
                       ];
        
        return s;
        
    }
    
    //MD5
+(NSString *)fileMD5:(NSString *)path
    {
        NSFileHandle *hanle=[NSFileHandle fileHandleForReadingAtPath:path];
        if(hanle==nil)
        {
            //        NSLog(@"Open file reading failed, path:%@", path);
            return @"";
        }
        CC_MD5_CTX md5;
        CC_MD5_Init(&md5);
        BOOL done=NO;
        while (!done) {
            NSData *fileData=[hanle readDataOfLength:1024];
            CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
            if([fileData length]==0)
            done=YES;
        }
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(digest, &md5);
        
        [hanle closeFile];
        
        NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                       digest[0], digest[1],
                       digest[2], digest[3],
                       digest[4], digest[5],
                       digest[6], digest[7],
                       digest[8], digest[9],
                       digest[10], digest[11],
                       digest[12], digest[13],
                       digest[14], digest[15]];
        return s;
        
        
    }
    
+(NSArray *)executablePathAndMD5Value{
    NSString * appPath = [[NSBundle mainBundle] executablePath];
    NSString* md5 = [TMMDeviceInfo fileMD5:appPath];
    if(nil == md5)
    md5 = @"";
    NSMutableArray *arr = [[NSMutableArray alloc]initWithObjects:appPath, md5,nil];
    return [NSArray arrayWithArray:arr];
}
    
    //越狱
+(BOOL)isJailBrojen
    {
        for(int i = 0; jailbreak_apps[i] != NULL; ++i)
        {
            if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]])
            {
                return YES;
            }
        }
        
        
        BOOL jailbroken = NO;
        NSString *cydiaPath = @"/Applications/Cydia.app";
        NSString *aptPath = @"/private/var/lib/apt/";
        if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
            jailbroken = YES;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
            jailbroken = YES;
        }
        return jailbroken;
        
        return NO;
        
    }
+(NSDictionary *)deviceInfo
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        
        [dic setObject:[TMMDeviceInfo deviceTypeDetail] forKey:@"DeviceType"];
        [dic setObject:[TMMDeviceInfo getOSVersion] forKey:@"DeviceOsType"];
        [dic setObject:[self getMacAddress] forKey:@"DeviceMac"];
        [dic setObject:[UIDevice currentDevice].model forKey:@"DeviceModel"];
        [dic setObject:[self getDeviceDisplayMetrics] forKey:@"DeviceMetrics"];
        [dic setObject:[TMMDeviceInfo cpuArchitectures] forKey:@"CPUArchitecture"];
        [dic setObject:[TMMDeviceInfo getBundleID] forKey:@"BundleID"];
        [dic setObject:[TMMDeviceInfo getAppVersion] forKey:@"AppVersion"];
        [dic setObject:[TMMDeviceInfo getApplicationName] forKey:@"AppName"];
        [dic setObject:[TMMDeviceInfo getDeviceIPAdress] forKey:@"IP"];
        [dic setObject:@([TMMDeviceInfo getBatteryLevel]) forKey:@"BatteryLevel"];
        [dic setObject:[TMMDeviceInfo getBatteryState] forKey:@"BatteryState"];
        [dic setObject:[TMMDeviceInfo getDeviceCountry] forKey:@"Country"];
        [dic setObject:[TMMDeviceInfo getCarrier] forKey:@"Carrier"];
        [dic setObject:[TMMDeviceInfo getDeviceLanguage] forKey:@"Language"];
        [dic setObject:[TMMDeviceInfo getTimezone] forKey:@"Timezone"];
        return dic;
    }

+ (NSString *) getDeviceName {
    return [[UIDevice currentDevice] name];
}

+ (NSString *) getSystemName {
    return [[UIDevice currentDevice] systemName];
}
    
+ (NSString *) getSystemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *) getUserAgent {
#if TARGET_OS_TV
    return nil;
#else
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    return [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
#endif
}
    
+ (NSString *)getDeviceDisplayMetrics {
    NSString *DisplayMetrics;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IPHONE5) {
            DisplayMetrics=@"1136*640";
        }
        if (iPhoneX) {
            DisplayMetrics = @"2436*1125";
        }
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            DisplayMetrics=@"960*640";
        }
        else {
            DisplayMetrics=@"480*320";
        }
    }else {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            DisplayMetrics=@"1024*768";
        }
        else {
            DisplayMetrics=@"2048*1536";
        }
    }
    return DisplayMetrics;
}
+ (NSString *)getMacAddress
    {
        int                 mgmtInfoBase[6];
        char                *msgBuffer = NULL;
        size_t              length;
        unsigned char       macAddress[6];
        struct if_msghdr    *interfaceMsgStruct;
        struct sockaddr_dl  *socketStruct;
        NSString            *errorFlag = NULL;
        NSString            *macAddressString = nil;
        
        mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
        mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
        mgmtInfoBase[2] = 0;
        mgmtInfoBase[3] = AF_LINK;        // Request link layer information
        mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
        
        if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
        else
        {
            if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
            else
            {
                if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
                else
                {
                    if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
                }
            }
        }
        
        // Befor going any further...
        if (errorFlag != NULL)
        {
            macAddressString = nil;
            
            // Release the buffer memory
            free(msgBuffer);
        }
        else
        {
            interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
            
            socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
            
            memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
            
            macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                macAddress[0], macAddress[1], macAddress[2],
                                macAddress[3], macAddress[4], macAddress[5]];
            
            free(msgBuffer);
        }
        
        
        if ([[[UIDevice currentDevice] systemVersion]intValue]<6)
        {
            if(macAddressString == nil || [macAddressString isEqualToString:@""])
            return @"000000000000";
            
            return macAddressString;
        }
        else if ([[[UIDevice currentDevice] systemVersion]intValue]==6)
        {
            if(macAddressString == nil || [macAddressString isEqualToString:@""])
            {
                
                NSString *UUIDString = [[[UIDevice currentDevice]identifierForVendor]UUIDString];
                if(UUIDString != nil && ![UUIDString isEqualToString:@""])
                return [UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
                else
                return @"000000000000";
                
            }
            else
            {
                return macAddressString;
            }
        }
        else
        {
            //所有iOS7设备mac地址都返回020000000000,在此直接用UUIDString代替
            
            //96FEADAA-884B-405A-A382-9E275FC15580
            NSString *UUIDString = [[[UIDevice currentDevice]identifierForVendor]UUIDString];
            if(UUIDString != nil && ![UUIDString isEqualToString:@""])
            return [UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
            else
            return @"000000000000";
        }
    }
    
+ (NSString *)cpuArchitectures{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}
    
+ (BOOL) isEmulator {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* deviceId = [NSString stringWithCString:systemInfo.machine
                                            encoding:NSUTF8StringEncoding];
    
    if ([deviceId isEqualToString:@"i386"] || [deviceId isEqualToString:@"x86_64"] ) {
        return YES;
    }
    return NO;
}

+ (BOOL) isTablet
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (NSString *) getCarrier {
#if (TARGET_OS_TV)
        return nil;
#else
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    return carrier.carrierName;
#endif
}

+ (NSString*) getDeviceCountry {
    NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    return country;
}

+ (NSString*) getTimezone {
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    return currentTimeZone.name;
}

+ (NSString*) getOSVersion {
    return [NSString stringWithFormat:@"%@ %@",[TMMDeviceInfo getSystemName],[TMMDeviceInfo getSystemVersion]];
}
    //获取设备型号
    //可根据https://www.theiphonewiki.com/wiki/Models#iPhone添加
+ (NSString*)deviceTypeDetail
    {
        // 需要#import "sys/utsname.h"
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        //iPhone
        if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
        if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
        if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
        if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
        if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
        if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
        if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
        if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
        if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
        if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
        if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
        if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
        if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
        if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
        if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
        if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
        if ([deviceString isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
        if ([deviceString isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
        if ([deviceString isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
        if ([deviceString isEqualToString:@"iPhone9,3"]) return @"iPhone 7";
        if ([deviceString isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
        if ([deviceString isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
        if ([deviceString isEqualToString:@"iPhone10,2"]) return @"iPhone 8";
        if ([deviceString isEqualToString:@"iPhone10,3"]) return @"iPhone X";
        if ([deviceString isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
        if ([deviceString isEqualToString:@"iPhone10,5"]) return @"iPhone 8";
        if ([deviceString isEqualToString:@"iPhone10,6"]) return @"iPhone X";
        
        //iPad
        if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
        if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
        if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
        if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
        if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
        if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
        if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
        if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
        
        if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
        if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
        if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
        if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
        if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
        if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
        
        if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air";
        if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air";
        if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air";
        if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
        if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
        if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
        if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
        
        if ([deviceString isEqualToString:@"iPad4,4"]||[deviceString isEqualToString:@"iPad4,5"]||[deviceString isEqualToString:@"iPad4,5"]||[deviceString isEqualToString:@"iPad4,6"]) {
            return @"iPad mini 2";
        }
        if ([deviceString isEqualToString:@"iPad4,7"]||[deviceString isEqualToString:@"iPad4,8"]||[deviceString isEqualToString:@"iPad4,9"]){
            return @"iPad mini 3";
        }
        
        return deviceString;
    }
    
    
+(NSDictionary *)appVersionInfo
    {
        
        NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
        
        //  CFShow((__bridge CFTypeRef)(infoDic));
        //app名称
        NSString *app_Name=[infoDic objectForKey:@"CFBundleDisplayName"];
        //app版本号
        NSString *app_Version=[infoDic objectForKey:@"CFBundleVersion"];
        //
        
        NSDictionary *versionDic=[NSDictionary dictionaryWithObjectsAndKeys:app_Name,@"VersionName",app_Version,@"VersionCode",@"",@"VersionType",@"",@"VersionSource", nil];
        
        return versionDic;
        
    }
    
    //getMainBundleMD5WithFlag方法为试验性的代码，上线时谨慎使用
    //flag 为1：每个文件的MD5追加存到同一个文件里，最后读取这个文件计算MD5.
    //flag 为2：每个文件的MD5追加存到同一个NSMutableString对象，再对这个对象内容计算MD5。如果文件很多，例如2000多个文件，NSMutableString对象会占用比较大的内存，再加上程序可用内存又不够多的话，恐怕会有问题。（在ios4.3设备上测试计算1200多个文件的MD5，暂时还没出现问题）
-(NSString*)getMainBundleMD5WithFlag:(NSInteger)flag
    {
        if(flag!=1 && flag!=2){
            return @"";
        }
        
        NSString *appPath = [[NSBundle mainBundle] resourcePath];
        
        //获取需要计算MD5的所有文件的路径
        self.dirFileList = [[NSMutableArray alloc] initWithCapacity:30];
        [self allFilesAtPath:appPath];
        
        NSMutableString *allFilesMD5string = [[NSMutableString alloc] init];
        NSFileHandle *outFile;
        NSString *filePath;
        NSFileManager *defaultManager;
        
        if(flag == 1)
        {
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            filePath = [documentsDirectory stringByAppendingPathComponent:@"md5.txt"];
            //        NSLog(@"md5filePath:%@",filePath);
            
            defaultManager = [NSFileManager defaultManager];//[[NSFileManager alloc]init];//
            if([defaultManager fileExistsAtPath:filePath]) {
                //以防万一,先删除已存在文件
                [defaultManager removeItemAtPath:filePath error:nil];
            }
            
            //重新创建文件,  NSFileHandle类没有提供创建文件的功能，所以必须使用NSFileManager来先创建文件
            [defaultManager createFileAtPath:filePath contents:nil attributes:nil];
            
            //打开文件, 用于写操作
            outFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
            if(outFile == nil)
            {
                //            NSLog(@"Open file writing failed, path:%@", filePath);
                return @"";
            }
        }
        
        
        while (self.dirFileList.count>0) {
            NSString *fileFullPathName = self.dirFileList[self.dirFileList.count-1];
            
            //NSLog(@"%d, fileFullPathName>>>>: %@",self.dirFileList.count-1,fileFullPathName);
            NSString *fileMD5 = [TMMDeviceInfo fileMD5:fileFullPathName];
            if(fileMD5!=nil && ![fileMD5 isEqualToString:@""])
            {
                
                if(flag == 1){
                    NSData *dataBuffer = [[fileMD5 stringByAppendingString:@"|"] dataUsingEncoding:NSUTF8StringEncoding];
                    //定位到文件的末尾位置(将在此追加文件内容)
                    [outFile seekToEndOfFile];
                    //将数据写入文件
                    [outFile writeData:dataBuffer];
                    
                }
                else
                {
                    [allFilesMD5string appendString:fileMD5];
                    [allFilesMD5string appendString:@"|"];
                }
                
            }
            
            [self.dirFileList removeObjectAtIndex:self.dirFileList.count-1];
        }
        
        
        if(self.dirFileList.count>0){
            [self.dirFileList removeAllObjects];
        }
        self.dirFileList = nil;//及时释放资源
        
        NSString *MD5;
        if(flag == 1)
        {
            //关闭写文件
            [outFile closeFile];
            //读文件MD5
            MD5 = [TMMDeviceInfo fileMD5:filePath];
            //取得MD5后，马上删除文件
            [defaultManager removeItemAtPath:filePath error:nil];
            
        }else
        {
            //NSLog(@"allFilesMD5string = %@",allFilesMD5string);
            //读数据MD5
            MD5 = [TMMDeviceInfo dataMD5:allFilesMD5string];
        }
        
        //    NSLog(@"MD5 = %@",MD5);
        if(MD5 == nil)
        MD5 = @"";
        
        return MD5;
    }
    
    //获取所有文件的全路径
- (void)allFilesAtPath:(NSString*)dirString
    {
        NSError *error = nil;
        NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirString error:&error];
        
        if(error)
        return;
        
        for (NSString *fileName in contentOfFolder) {
            
            NSString * fullPath = [dirString stringByAppendingPathComponent:fileName];
            
            BOOL isDir;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir){
                
                // ignore .DS_Store,忽略隐藏文件
                //说明:计算太多文件的MD5，会影响程序启动速度，在此可以根据需要忽略掉一些文件，比如图片文件
                if (![[fileName substringToIndex:1] isEqualToString:@"."]
                    && ![fileName isEqualToString:@"CodeResources"]
                    && ![fileName isEqualToString:@"ResourceRules.plist"]
                    && ![fileName isEqualToString:@"PkgInfo"]
                    && ![fileName hasSuffix:@".mobileprovision"]
                    && ![fileName hasSuffix:@".png"] && ![fileName hasSuffix:@".jpg"] && ![fileName hasSuffix:@".bmp"] && ![fileName hasSuffix:@".aiff"] && ![fileName hasSuffix:@".gif"] && ![fileName hasSuffix:@".mp4"] && ![fileName hasSuffix:@".wav"] ) {
                    [self.dirFileList addObject:fullPath];
                }
            }else{
                
                //过滤掉某些文件夹，SC_Info里的文件包含每个用户自己的AppStore账号信息，不能参与计算MD5
                if(![fileName isEqualToString:@"_CodeSignature"]
                   && ![fileName isEqualToString:@"SC_Info"]
                   /*&& ![fileName isEqualToString:@"xface"]*/
                   && ![fileName hasSuffix:@".bundle"])
                {
                    [self allFilesAtPath:fullPath];
                }
            }
            
        }
    }
    
+ (NSString *) getDeviceIPAdress {
    
    NSString *address = @"an error occurred when obtaining ip address";
    
    struct ifaddrs *interfaces = NULL;
    
    struct ifaddrs *temp_addr = NULL;
    
    int success = 0;
    
    
    
    success = getifaddrs(&interfaces);
    
    
    
    if (success == 0) { // 0 表示获取成功
        
        
        
        temp_addr = interfaces;
        
        while (temp_addr != NULL) {
            
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                
                // Check if interface is en0 which is the wifi connection on the iPhone
                
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    
                    // Get NSString from C String
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    return address;
}
    
+(NSString*) getApplicationName{
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (appName == nil) {
        NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        if (bundleName == nil) {
            return @"";
        }
        NSMutableString *mutableAppName = [NSMutableString stringWithString:bundleName];
        return [mutableAppName copy];
    }
    NSMutableString *mutableAppName = [NSMutableString stringWithString:appName];
    return [mutableAppName copy];
}
    
+(NSString*) getBundleID {
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
}
 
+ (NSString *) getAppVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
    
+ (NSString *) getBuildVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}
    
+ (CGFloat) getBatteryLevel {
    
    UIApplication *app = [UIApplication sharedApplication];
    
    if (app.applicationState == UIApplicationStateActive||app.applicationState==UIApplicationStateInactive) {
        
        Ivar ivar=  class_getInstanceVariable([app class],"_statusBar");
        
        id status  = object_getIvar(app, ivar);
        
        for (id aview in [status subviews]) {
            
            int batteryLevel = 0;
            
            for (id bview in [aview subviews]) {
                
                if ([NSStringFromClass([bview class]) caseInsensitiveCompare:@"UIStatusBarBatteryItemView"] == NSOrderedSame&&[[[UIDevice currentDevice] systemVersion] floatValue] >=6.0) {
                    
                    Ivar ivar=  class_getInstanceVariable([bview class],"_capacity");
                    
                    if(ivar) {
                        
                        batteryLevel = ((int (*)(id, Ivar))object_getIvar)(bview, ivar);
                        
                        if (batteryLevel > 0 && batteryLevel <= 100) {
                            
                            return batteryLevel;
                            
                        } else {
                            return 0;
                        }
                    }
                }
            }
        }
    }
    return 0;
    
}
    
+ (NSString *) getBatteryState {
    
    UIDevice *device = [UIDevice currentDevice];
    
    if (device.batteryState == UIDeviceBatteryStateUnknown) {
        
        return @"UnKnow";
        
    } else if (device.batteryState == UIDeviceBatteryStateUnplugged){
        
        return @"Unplugged";
        
    } else if (device.batteryState == UIDeviceBatteryStateCharging){
        
        return @"Charging";
        
    } else if (device.batteryState == UIDeviceBatteryStateFull){
        
        return @"Full";
        
    }
    
    return nil;
    
}
    
    
+ (NSString *)getDeviceLanguage {
    
    NSArray *languageArray = [NSLocale preferredLanguages];
    
    return [languageArray objectAtIndex:0];
    
}
    
+ (void)deleteIDFA {
    [TMMKeyChainStore removeItemForKey:IDFA_KEY service:IDFA_SERVICE];
}
    
+ (NSString*)IDFA {
    //0.读取keychain的缓存
    NSString *deviceID = [TMMDeviceInfo getIdfaString];
    if (kIsStringValid(deviceID)) {
        return deviceID;
    } else {
        //1.取IDFA,可能会取不到,如用户关闭IDFA
        if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
            deviceID = [[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] lowercaseString];
            [TMMDeviceInfo setIdfaString:deviceID];
            return deviceID;
        } else {
            //2.如果取不到,就生成UUID,当成IDFA
            deviceID = [TMMDeviceInfo getUUID];
            [TMMDeviceInfo setIdfaString:deviceID];
            if (kIsStringValid(deviceID)) {
                return deviceID;
            }
        }
    }
    //3.再取不到尼玛我也没办法了,你牛B.
    return nil;
}

#pragma mark - Keychain
+ (NSString*)getIdfaString {
    TMMKeyChainStore *keychain = [TMMKeyChainStore keyChainStoreWithService:IDFA_SERVICE];
    NSString *idfaStr = [keychain stringForKey:IDFA_KEY];
    if (kIsStringValid(idfaStr)) {
        return idfaStr;
    } else {
        return nil;
    }
}
    
+ (BOOL)setIdfaString:(NSString *)secValue {
    if (kIsStringValid(secValue)) {
        TMMKeyChainStore *keychain = [TMMKeyChainStore keyChainStoreWithService:IDFA_SERVICE];
        [keychain setString:secValue forKey:IDFA_KEY];
        keychain.synchronizable = YES;
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UUID
+ (NSString*)getUUID{
    CFUUIDRef uuid_ref = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuid_string_ref= CFUUIDCreateString(kCFAllocatorDefault, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    if (!kIsStringValid(uuid))
    {
        uuid = @"";
    }
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}
@end
