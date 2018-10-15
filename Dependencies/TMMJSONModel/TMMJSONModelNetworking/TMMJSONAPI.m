//
//  TMMJSONAPI.m
//  TMMJSONModel
//

#import "TMMJSONAPI.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"

#pragma mark - helper error model class
@interface TMMJSONAPIRPCErrorModel: TMMJSONModel
@property (assign, nonatomic) int code;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) id<Optional> data;
@end

#pragma mark - static variables

static TMMJSONAPI* sharedInstance = nil;

static long jsonRpcId = 0;

#pragma mark - TMMJSONAPI() private interface

@interface TMMJSONAPI ()
@property (strong, nonatomic) NSString* baseURLString;
@end

#pragma mark - TMMJSONAPI implementation

@implementation TMMJSONAPI

#pragma mark - initialize

+(void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[TMMJSONAPI alloc] init];
    });
}

#pragma mark - api config methods

+(void)setAPIBaseURLWithString:(NSString*)base
{
    sharedInstance.baseURLString = base;
}

+(void)setContentType:(NSString*)ctype
{
    [TMMJSONHTTPClient setRequestContentType: ctype];
}

#pragma mark - GET methods
+(void)getWithPath:(NSString*)path andParams:(NSDictionary*)params completion:(TMMJSONObjectBlock)completeBlock
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];

    [TMMJSONHTTPClient getJSONFromURLWithString: fullURL params:params completion:^(NSDictionary *json, TMMJSONModelError *e) {
        completeBlock(json, e);
    }];
}

#pragma mark - POST methods
+(void)postWithPath:(NSString*)path andParams:(NSDictionary*)params completion:(TMMJSONObjectBlock)completeBlock
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];

    [TMMJSONHTTPClient postJSONFromURLWithString: fullURL params:params completion:^(NSDictionary *json, TMMJSONModelError *e) {
        completeBlock(json, e);
    }];
}

#pragma mark - RPC methods
+(void)__rpcRequestWithObject:(id)jsonObject completion:(TMMJSONObjectBlock)completeBlock
{

    NSData* jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                              options:kNilOptions
                                                                error:nil];
    NSString* jsonRequestString = [[NSString alloc] initWithData:jsonRequestData encoding: NSUTF8StringEncoding];

    NSAssert(sharedInstance.baseURLString, @"API base URL not set");
    [TMMJSONHTTPClient postJSONFromURLWithString: sharedInstance.baseURLString
                                   bodyString: jsonRequestString
                                   completion:^(NSDictionary *json, TMMJSONModelError* e) {

                                       if (completeBlock) {
                                           //handle the rpc response
                                           NSDictionary* result = json[@"result"];

                                           if (!result) {
                                               TMMJSONAPIRPCErrorModel* error = [[TMMJSONAPIRPCErrorModel alloc] initWithDictionary:json[@"error"] error:nil];
                                               if (error) {
                                                   //custom server error
                                                   if (!error.message) error.message = @"Generic json rpc error";
                                                   e = [TMMJSONModelError errorWithDomain:TMMJSONModelErrorDomain
                                                                                  code:error.code
                                                                              userInfo: @{ NSLocalizedDescriptionKey : error.message}];
                                               } else {
                                                   //generic error
                                                   e = [TMMJSONModelError errorBadResponse];
                                               }
                                           }

                                           //invoke the callback
                                           completeBlock(result, e);
                                       }
                                   }];
}

+(void)rpcWithMethodName:(NSString*)method andArguments:(NSArray*)args completion:(TMMJSONObjectBlock)completeBlock
{
    NSAssert(method, @"No method specified");
    if (!args) args = @[];

    [self __rpcRequestWithObject:@{
                                  //rpc 1.0
                                  @"id": @(++jsonRpcId),
                                  @"params": args,
                                  @"method": method
     } completion:completeBlock];
}

+(void)rpc2WithMethodName:(NSString*)method andParams:(id)params completion:(TMMJSONObjectBlock)completeBlock
{
    NSAssert(method, @"No method specified");
    if (!params) params = @[];

    [self __rpcRequestWithObject:@{
                                  //rpc 2.0
                                  @"jsonrpc": @"2.0",
                                  @"id": @(++jsonRpcId),
                                  @"params": params,
                                  @"method": method
     } completion:completeBlock];
}

@end

#pragma mark - helper rpc error model class implementation
@implementation TMMJSONAPIRPCErrorModel
@end
