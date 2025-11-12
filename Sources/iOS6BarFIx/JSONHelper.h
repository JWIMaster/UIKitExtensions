#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSONHelper : NSObject

+ (nullable NSDictionary *)parseJSON:(NSString *)json;

@end

NS_ASSUME_NONNULL_END
