#import "HSItem.h"

@interface HSFilter : HSItem

+ (NSArray *)filters:(NSError **)error;

- (unsigned int)filterID;
- (NSString *)filterIDString;
- (NSString *)filterName;
- (NSString *)folder;
- (NSDictionary *)columns;
- (BOOL)global;
- (unsigned int)count;
- (unsigned int)unread;

- (NSArray *)requests:(NSError **)error;
- (NSArray *)requestsInRange:(NSRange)r error:(NSError **)error;

@end
