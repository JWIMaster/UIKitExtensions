#import "JSONHelper.h"

@implementation JSONHelper

+ (NSDictionary *)parseJSON:(NSString *)json {
    NSError *error = nil;
    NSData *encodedResponseString = [json dataUsingEncoding:NSUTF8StringEncoding];
    id parsedResponse = [NSJSONSerialization JSONObjectWithData:encodedResponseString options:0 error:&error];
    
    if ([parsedResponse isKindOfClass:[NSDictionary class]]) {
        return parsedResponse;
    }
    return nil;
}

@end
