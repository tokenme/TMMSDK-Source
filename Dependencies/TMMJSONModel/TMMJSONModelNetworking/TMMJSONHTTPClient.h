//
//  TMMJSONModelHTTPClient.h
//  TMMJSONModel
//

#import "TMMJSONModel.h"

extern NSString *const kHTTPMethodGET DEPRECATED_ATTRIBUTE;
extern NSString *const kHTTPMethodPOST DEPRECATED_ATTRIBUTE;
extern NSString *const kContentTypeAutomatic DEPRECATED_ATTRIBUTE;
extern NSString *const kContentTypeJSON DEPRECATED_ATTRIBUTE;
extern NSString *const kContentTypeWWWEncoded DEPRECATED_ATTRIBUTE;

typedef void (^TMMJSONObjectBlock)(id json, TMMJSONModelError *err) DEPRECATED_ATTRIBUTE;

DEPRECATED_ATTRIBUTE
@interface TMMJSONHTTPClient : NSObject

+ (NSMutableDictionary *)requestHeaders DEPRECATED_ATTRIBUTE;
+ (void)setDefaultTextEncoding:(NSStringEncoding)encoding DEPRECATED_ATTRIBUTE;
+ (void)setCachingPolicy:(NSURLRequestCachePolicy)policy DEPRECATED_ATTRIBUTE;
+ (void)setTimeoutInSeconds:(int)seconds DEPRECATED_ATTRIBUTE;
+ (void)setRequestContentType:(NSString *)contentTypeString DEPRECATED_ATTRIBUTE;
+ (void)getJSONFromURLWithString:(NSString *)urlString completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)getJSONFromURLWithString:(NSString *)urlString params:(NSDictionary *)params completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)JSONFromURLWithString:(NSString *)urlString method:(NSString *)method params:(NSDictionary *)params orBodyString:(NSString *)bodyString completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)JSONFromURLWithString:(NSString *)urlString method:(NSString *)method params:(NSDictionary *)params orBodyString:(NSString *)bodyString headers:(NSDictionary *)headers completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)JSONFromURLWithString:(NSString *)urlString method:(NSString *)method params:(NSDictionary *)params orBodyData:(NSData *)bodyData headers:(NSDictionary *)headers completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postJSONFromURLWithString:(NSString *)urlString params:(NSDictionary *)params completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postJSONFromURLWithString:(NSString *)urlString bodyString:(NSString *)bodyString completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postJSONFromURLWithString:(NSString *)urlString bodyData:(NSData *)bodyData completion:(TMMJSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
