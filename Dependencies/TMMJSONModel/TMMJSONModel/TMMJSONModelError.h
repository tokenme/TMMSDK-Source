//
//  TMMJSONModelError.h
//  TMMJSONModel
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////////////////////////
typedef NS_ENUM(int, kTMMJSONModelErrorTypes)
{
    kTMMJSONModelErrorInvalidData = 1,
    kTMMJSONModelErrorBadResponse = 2,
    kTMMJSONModelErrorBadJSON = 3,
    kTMMJSONModelErrorModelIsInvalid = 4,
    kTMMJSONModelErrorNilInput = 5
};

/////////////////////////////////////////////////////////////////////////////////////////////
/** The domain name used for the TMMJSONModelError instances */
extern NSString *const TMMJSONModelErrorDomain;

/**
 * If the model JSON input misses keys that are required, check the
 * userInfo dictionary of the TMMJSONModelError instance you get back -
 * under the kTMMJSONModelMissingKeys key you will find a list of the
 * names of the missing keys.
 */
extern NSString *const kTMMJSONModelMissingKeys;

/**
 * If JSON input has a different type than expected by the model, check the
 * userInfo dictionary of the TMMJSONModelError instance you get back -
 * under the kTMMJSONModelTypeMismatch key you will find a description
 * of the mismatched types.
 */
extern NSString *const kTMMJSONModelTypeMismatch;

/**
 * If an error occurs in a nested model, check the userInfo dictionary of
 * the TMMJSONModelError instance you get back - under the kTMMJSONModelKeyPath
 * key you will find key-path at which the error occurred.
 */
extern NSString *const kTMMJSONModelKeyPath;

/////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Custom NSError subclass with shortcut methods for creating
 * the common TMMJSONModel errors
 */
@interface TMMJSONModelError : NSError

@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;

@property (strong, nonatomic) NSData *responseData;

/**
 * Creates a TMMJSONModelError instance with code kTMMJSONModelErrorInvalidData = 1
 */
+ (id)errorInvalidDataWithMessage:(NSString *)message;

/**
 * Creates a TMMJSONModelError instance with code kTMMJSONModelErrorInvalidData = 1
 * @param keys a set of field names that were required, but not found in the input
 */
+ (id)errorInvalidDataWithMissingKeys:(NSSet *)keys;

/**
 * Creates a TMMJSONModelError instance with code kTMMJSONModelErrorInvalidData = 1
 * @param mismatchDescription description of the type mismatch that was encountered.
 */
+ (id)errorInvalidDataWithTypeMismatch:(NSString *)mismatchDescription;

/**
 * Creates a TMMJSONModelError instance with code kTMMJSONModelErrorBadResponse = 2
 */
+ (id)errorBadResponse;

/**
 * Creates a TMMJSONModelError instance with code kTMMJSONModelErrorBadJSON = 3
 */
+ (id)errorBadJSON;

/**
 * Creates a TMMJSONModelError instance with code kTMMJSONModelErrorModelIsInvalid = 4
 */
+ (id)errorModelIsInvalid;

/**
 * Creates a TMMJSONModelError instance with code kTMMJSONModelErrorNilInput = 5
 */
+ (id)errorInputIsNil;

/**
 * Creates a new TMMJSONModelError with the same values plus information about the key-path of the error.
 * Properties in the new error object are the same as those from the receiver,
 * except that a new key kTMMJSONModelKeyPath is added to the userInfo dictionary.
 * This key contains the component string parameter. If the key is already present
 * then the new error object has the component string prepended to the existing value.
 */
- (instancetype)errorByPrependingKeyPathComponent:(NSString *)component;

/////////////////////////////////////////////////////////////////////////////////////////////
@end
