//
//  TMMAES256.h
//  TMMSDK
//
//  Created by Syd on 2018/7/30.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#ifndef TMMAES256_h
#define TMMAES256_h

@interface TMMAES256 : NSObject

+(NSData *)AES256ParmEncryptWithKey:(NSString *)key Encrypttext:(NSData *)text;   //加密

+(NSData *)AES256ParmDecryptWithKey:(NSString *)key Decrypttext:(NSData *)text;   //解密

+(NSString *)AES256Encrypt:(NSString *)key Encrypttext:(NSString *)text;

+(NSString *)AES256Decrypt:(NSString *)key Decrypttext:(NSString *)text;



@end

#endif /* TMMAES256_h */
