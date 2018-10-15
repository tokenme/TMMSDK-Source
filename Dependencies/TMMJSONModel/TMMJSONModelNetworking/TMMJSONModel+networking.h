//
//  TMMJSONModel+networking.h
//  TMMJSONModel
//

#import "TMMJSONModel.h"
#import "TMMJSONHTTPClient.h"

typedef void (^TMMJSONModelBlock)(id model, TMMJSONModelError *err) DEPRECATED_ATTRIBUTE;

@interface TMMJSONModel (Networking)

@property (assign, nonatomic) BOOL isLoading DEPRECATED_ATTRIBUTE;
- (instancetype)initFromURLWithString:(NSString *)urlString completion:(TMMJSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)getModelFromURLWithString:(NSString *)urlString completion:(TMMJSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postModel:(TMMJSONModel *)post toURLWithString:(NSString *)urlString completion:(TMMJSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
