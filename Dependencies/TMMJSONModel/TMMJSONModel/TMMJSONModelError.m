//
//  TMMJSONModelError.m
//  TMMJSONModel
//

#import "TMMJSONModelError.h"

NSString* const TMMJSONModelErrorDomain = @"TMMJSONModelErrorDomain";
NSString* const kTMMJSONModelMissingKeys = @"kTMMJSONModelMissingKeys";
NSString* const kTMMJSONModelTypeMismatch = @"kTMMJSONModelTypeMismatch";
NSString* const kTMMJSONModelKeyPath = @"kTMMJSONModelKeyPath";

@implementation TMMJSONModelError

+(id)errorInvalidDataWithMessage:(NSString*)message
{
    message = [NSString stringWithFormat:@"Invalid JSON data: %@", message];
    return [TMMJSONModelError errorWithDomain:TMMJSONModelErrorDomain
                                      code:kTMMJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:message}];
}

+(id)errorInvalidDataWithMissingKeys:(NSSet *)keys
{
    return [TMMJSONModelError errorWithDomain:TMMJSONModelErrorDomain
                                      code:kTMMJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON data. Required JSON keys are missing from the input. Check the error user information.",kTMMJSONModelMissingKeys:[keys allObjects]}];
}

+(id)errorInvalidDataWithTypeMismatch:(NSString*)mismatchDescription
{
    return [TMMJSONModelError errorWithDomain:TMMJSONModelErrorDomain
                                      code:kTMMJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON data. The JSON type mismatches the expected type. Check the error user information.",kTMMJSONModelTypeMismatch:mismatchDescription}];
}

+(id)errorBadResponse
{
    return [TMMJSONModelError errorWithDomain:TMMJSONModelErrorDomain
                                      code:kTMMJSONModelErrorBadResponse
                                  userInfo:@{NSLocalizedDescriptionKey:@"Bad network response. Probably the JSON URL is unreachable."}];
}

+(id)errorBadJSON
{
    return [TMMJSONModelError errorWithDomain:TMMJSONModelErrorDomain
                                      code:kTMMJSONModelErrorBadJSON
                                  userInfo:@{NSLocalizedDescriptionKey:@"Malformed JSON. Check the TMMJSONModel data input."}];
}

+(id)errorModelIsInvalid
{
    return [TMMJSONModelError errorWithDomain:TMMJSONModelErrorDomain
                                      code:kTMMJSONModelErrorModelIsInvalid
                                  userInfo:@{NSLocalizedDescriptionKey:@"Model does not validate. The custom validation for the input data failed."}];
}

+(id)errorInputIsNil
{
    return [TMMJSONModelError errorWithDomain:TMMJSONModelErrorDomain
                                      code:kTMMJSONModelErrorNilInput
                                  userInfo:@{NSLocalizedDescriptionKey:@"Initializing model with nil input object."}];
}

- (instancetype)errorByPrependingKeyPathComponent:(NSString*)component
{
    // Create a mutable  copy of the user info so that we can add to it and update it
    NSMutableDictionary* userInfo = [self.userInfo mutableCopy];

    // Create or update the key-path
    NSString* existingPath = userInfo[kTMMJSONModelKeyPath];
    NSString* separator = [existingPath hasPrefix:@"["] ? @"" : @".";
    NSString* updatedPath = (existingPath == nil) ? component : [component stringByAppendingFormat:@"%@%@", separator, existingPath];
    userInfo[kTMMJSONModelKeyPath] = updatedPath;

    // Create the new error
    return [TMMJSONModelError errorWithDomain:self.domain
                                      code:self.code
                                  userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
}

@end
