//
//  TMMJSONAPI.h
//  TMMJSONModel
//

#import <Foundation/Foundation.h>
#import "TMMJSONHTTPClient.h"

DEPRECATED_ATTRIBUTE
@interface TMMJSONAPI : NSObject

+ (void)setAPIBaseURLWithString:(NSString *)base DEPRECATED_ATTRIBUTE;
+ (void)setContentType:(NSString *)ctype DEPRECATED_ATTRIBUTE;
+ (void)getWithPath:(NSString *)path andParams:(NSDictionary *)params completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postWithPath:(NSString *)path andParams:(NSDictionary *)params completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)rpcWithMethodName:(NSString *)method andArguments:(NSArray *)args completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)rpc2WithMethodName:(NSString *)method andParams:(id)params completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
