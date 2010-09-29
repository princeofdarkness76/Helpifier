#import "HSItem.h"

#define HSAuthenticationMethodURL 0
#define HSAuthenticationMethodHTTPBasic 1

@class HSPerson;

@interface HSWorkspace : NSObject

+ (HSWorkspace *)sharedWorkspace;

- (NSURL *)url;
- (void)setAuthenticationUsername:(NSString *)u
						 password:(NSString *)p
						   method:(unsigned int)m;
- (unsigned int)authenticationMethod;

- (HSPerson *)user:(NSError **)error;

- (NSArray *)categories:(NSError **)error;
- (NSArray *)customFields:(NSError **)error;
- (NSDictionary *)labels:(NSError **)error;
- (NSArray *)staff:(NSError **)error;
- (NSArray *)mailboxes:(BOOL)activeOnly error:(NSError **)error;

- (NSString *)passwordForEmail:(NSString *)email error:(NSError **)error;
- (BOOL)setPassword:(NSString *)pwd forEmail:(NSString *)email error:(NSError **)error;

@end



@interface HSCategory : HSItem

- (unsigned int)categoryID;
- (NSString *)name;
- (NSIndexSet *)customFieldIDs;
- (BOOL)deleted;
- (BOOL)allowPublicSubmit;
- (unsigned int)defaultPersonID;
- (BOOL)autoAssign;

- (NSArray *)persons;
- (NSArray *)reportingTags;

@end



@interface HSCustomField : HSItem

- (unsigned int)fieldID;
- (NSString *)name;
- (unsigned int)order;
- (BOOL)isAlwaysVisible;
- (BOOL)isRequired;
- (BOOL)isPublic;

- (NSString *)type;
- (NSArray *)listItems;
- (unsigned int)textFieldSize;
- (unsigned int)largeTextFieldRows;
- (NSString *)regex;
- (NSURL *)ajaxURL;
- (unsigned int)decimalPlaces;

@end


@interface HSMailbox : HSItem

- (unsigned int)mailboxID;
- (NSString *)name;
- (NSString *)email;

@end


@interface HSReportingTag : HSItem

- (unsigned int)reportingTagID;
- (NSString *)name;

@end


