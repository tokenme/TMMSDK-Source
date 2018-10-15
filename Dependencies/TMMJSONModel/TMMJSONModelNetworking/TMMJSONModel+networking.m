//
//  TMMJSONModel+networking.m
//  TMMJSONModel
//

#import "TMMJSONModel+networking.h"
#import "TMMJSONHTTPClient.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"

BOOL _isLoading;

@implementation TMMJSONModel(Networking)

@dynamic isLoading;

-(BOOL)isLoading
{
    return _isLoading;
}

-(void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
}

-(instancetype)initFromURLWithString:(NSString *)urlString completion:(TMMJSONModelBlock)completeBlock
{
    id placeholder = [super init];
    __block id blockSelf = self;

    if (placeholder) {
        //initialization
        self.isLoading = YES;

        [TMMJSONHTTPClient getJSONFromURLWithString:urlString
                                      completion:^(NSDictionary *json, TMMJSONModelError* e) {

                                          TMMJSONModelError* initError = nil;
                                          blockSelf = [self initWithDictionary:json error:&initError];

                                          if (completeBlock) {
                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                                                  completeBlock(blockSelf, e?e:initError );
                                              });
                                          }

                                          self.isLoading = NO;

                                      }];
    }
    return placeholder;
}

+ (void)getModelFromURLWithString:(NSString*)urlString completion:(TMMJSONModelBlock)completeBlock
{
    [TMMJSONHTTPClient getJSONFromURLWithString:urlString
                                  completion:^(NSDictionary* jsonDict, TMMJSONModelError* err)
    {
        TMMJSONModel* model = nil;

        if(err == nil)
        {
            model = [[self alloc] initWithDictionary:jsonDict error:&err];
        }

        if(completeBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                completeBlock(model, err);
            });
        }
    }];
}

+ (void)postModel:(TMMJSONModel*)post toURLWithString:(NSString*)urlString completion:(TMMJSONModelBlock)completeBlock
{
    [TMMJSONHTTPClient postJSONFromURLWithString:urlString
                                   bodyString:[post toJSONString]
                                   completion:^(NSDictionary* jsonDict, TMMJSONModelError* err)
    {
        TMMJSONModel* model = nil;

        if(err == nil)
        {
            model = [[self alloc] initWithDictionary:jsonDict error:&err];
        }

        if(completeBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                completeBlock(model, err);
            });
        }
    }];
}

@end
