//
//  TMMApi.h
//  TMMSDK
//
//  Created by Syd on 2018/7/31.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#ifndef TMMAPI_h
#define TMMAPI_h

@interface TMMApi: NSObject
+ (void)callMethod:(NSString *)method
           payload:(NSString *)payload
               key:(NSString *)apiKey
            secret:(NSString *)secret
           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
#endif /* TMMAPI_h */
