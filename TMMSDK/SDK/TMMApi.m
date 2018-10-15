//
//  TMMApi.m
//  TMMSDK
//
//  Created by Syd on 2018/7/31.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMAFNetworking.h"
#import "TMMApi.h"
#import "NSString+Hashes.h"

NSString * const kAPI_VERSION = @"1";
NSString * const kAPI_GATEWAY = @"https://tmm.tokenmama.io";

@implementation TMMApi

+ (void)callMethod:(NSString *)method
           payload:(NSString *)payload
               key:(NSString *)apiKey
            secret:(NSString *)secret
           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NSTimeInterval ts    = [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"k"] = apiKey; // app_key
    parameters[@"v"] = kAPI_VERSION; // api version
    parameters[@"t"] = [NSNumber numberWithInteger:round(ts)]; // timestamp
    parameters[@"r"] = [TMMApi randomAlphanumericStringWithLength:40]; // random string key
    parameters[@"p"] = payload; // data
    parameters[@"s"] = [TMMApi signByParams:[parameters copy] secret:secret]; // sign
    
    
    //[kApplication setNetworkActivityIndicatorVisible:YES];
    TMMAFHTTPSessionManager *session = [TMMAFHTTPSessionManager manager];
    [session POST:[@[kAPI_GATEWAY, method] componentsJoinedByString:@"/"]
       parameters:[parameters copy]
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              //[kApplication setNetworkActivityIndicatorVisible:NO];
              //NSLog(@"resp: %@", responseObject);
              if (responseObject) {
                  if (responseObject[@"msg"] != [NSNull null]) {
                      if ([responseObject[@"msg"] isKindOfClass:[NSString class]] && [responseObject[@"msg"] isEqualToString:@"invalid_ts"]) {
                          //
                      }
                  }
              }
              if (success) {
                  success(task, responseObject);
              }
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              //[kApplication setNetworkActivityIndicatorVisible:NO];
              //NSLog(@"error: %@", error);
              if (failure) {
                  failure(task, error);
              }
          }];
}

# pragma mark - API Helper

+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!^*()_+{}|\\:=";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
}

+ (NSString *)signByParams:(NSDictionary *)params secret:(NSString *)secret {
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSString *key in sortedKeys) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:[NSString stringWithFormat:@"%@", key]
                                                          value:[NSString stringWithFormat:@"%@", params[key]]
                               ]];
    }
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.queryItems = queryItems;
    return [[NSString stringWithFormat:@"%@%@%@", secret, components.query, secret] sha1Hash];
}

@end
