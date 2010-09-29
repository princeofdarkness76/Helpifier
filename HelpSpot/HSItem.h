#import <Cocoa/Cocoa.h>

@interface HSItem : NSObject
{
	NSMutableDictionary *content;
}

- (id)initWithContent:(NSDictionary *)c;

@end
