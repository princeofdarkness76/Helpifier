#import "HSItem.h"

@interface HSPerson : HSItem

- (unsigned int)personID;
- (NSString *)fullName;
- (NSString *)firstName;
- (NSString *)lastName;
- (NSString *)username;
- (NSString *)primaryEmail;
- (NSString *)secondaryEmail;
- (NSString *)sms;
- (unsigned int)smsServiceID;
- (NSString *)phone;
- (NSString *)signature;
- (NSString *)signatureHTML;
- (NSString *)mobileSignature;

- (BOOL)notifyPrimaryEmail;
- (BOOL)notifySecondaryEmail;
- (BOOL)notifySMS;
- (BOOL)notifySMSUrgent;
- (unsigned int)photoID;
- (BOOL)userType;
- (unsigned int)outOfOffice;
- (BOOL)notifyOfNewRequest;
- (NSString *)workspace;
- (BOOL)defaultToPublic;
- (BOOL)defaultTTOpen;
- (BOOL)hideWYSIWYG;
- (BOOL)hideImages;
- (unsigned int)requestHistoryLimit;
- (BOOL)returnToRequest;
- (NSString *)htmlEditor;

- (unsigned int)assignedRequests;
- (BOOL)deleted;

@end
