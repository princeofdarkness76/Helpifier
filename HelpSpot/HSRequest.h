#import "HSItem.h"

@class HSRequestHistoryItem;
@class HSRequestAttachment;
@class HSMailbox;

@interface HSRequestDescription : HSItem

+ (NSArray *)descriptionsForEmail:(NSString *)email password:(NSString *)pwd error:(NSError **)error;
+ (HSRequestDescription *)descriptionWithContent:(NSDictionary *)c;

- (unsigned int)requestID;
- (NSString *)accessKey;

- (BOOL)isOpen;
- (unsigned int)status;
- (BOOL)urgent;

- (NSArray *)timeEvents:(NSError **)error;

@end

@interface HSRequest : HSRequestDescription
{
	unsigned int fileNumber;
}

+ (HSRequest *)requestWithID:(unsigned int)requestID error:(NSError **)error;
+ (HSRequest *)requestForAccessKey:(NSString *)accessKey error:(NSError **)error;
+ (NSArray *)requestsForQuery:(NSString *)query error:(NSError **)error;
+ (HSRequest *)request;

- (BOOL)add:(NSError **)error;
- (BOOL)update:(NSError **)error;
- (BOOL)addTimeTrackerEvent:(NSString *)description date:(NSDate *)date personID:(unsigned int)personID length:(double)seconds error:(NSError **)error;

- (void) get;

- (void)setRequestID:(unsigned int)r;
- (void)setAccessKey:(NSString *)k;
- (unsigned int)userID;
- (void)setUserID:(unsigned int)userID;
- (NSString *)firstName;
- (void)setFirstName:(NSString *)name;
- (NSString *)lastName;
- (void)setLastName:(NSString *)name;
- (NSString *)fullName;
- (NSString *)email;
- (void)setEmail:(NSString *)email;
- (NSString *)phone;
- (void)setPhone:(NSString *)phone;
- (NSString *)body;
- (void)setBody:(NSString *)body;
- (NSAttributedString *) bodyAttributedString;
- (void)setBodyAttributedString:(NSAttributedString *)b;
- (NSString *)category;
- (void)setCategoryID:(unsigned int)catID;
- (NSString *)valueForCustomField:(unsigned int)field;
- (void)setValue:(NSString *)value forCustomField:(unsigned int)field;
- (NSString *)valueForKey:(NSString *)key;
- (void)setValue:(NSString *)value forKey:(NSString *)key;

- (unsigned int)type;
- (void)setType:(unsigned int)t;
- (void)setIsOpen:(BOOL)o;
- (void)setStatus:(unsigned int)x;
- (void)setUrgent:(BOOL)u;
- (BOOL)isUnread;
- (void)setIsUnread:(BOOL)u;
- (NSString *)openedVia;
- (void)setOpenedVia:(NSString *)o;
- (unsigned int)openedViaID;
- (NSString *)openedBy;
- (NSString *)assignedTo;
- (void)setAssignedTo:(NSString *)a;
- (NSDate *)opened;
- (void)setOpened:(NSDate *)d;
- (NSDate *)closed;
- (NSString *)password;
- (NSString *)title;
- (void)setTitle:(NSString *)t;
- (NSString *)lastReplyBy;
- (BOOL)trash;
- (void)setTrash:(BOOL)f;
- (NSDate *)trashed;

- (void)setReportingTags:(NSArray *)reportingTags;
- (void)setFromMailbox:(HSMailbox *)mailbox;
- (void)setEmailCC:(NSArray *)emails;
- (void)setEmailBCC:(NSArray *)emails;
- (void)setEmailTo:(NSArray *)emails;
- (void)setEmailStaff:(NSArray *)persons;

- (void)addFileWithName:(NSString *)name mimeType:(NSString *)type content:(NSData *)data;

- (unsigned int)numberOfHistoryItems;
- (HSRequestHistoryItem *)historyItemAtIndex:(unsigned int)index;

@end



@interface HSRequestHistoryItem : HSItem

- (unsigned int)requestHistoryItemID;
- (unsigned int)requestID;

- (NSString *)fullName;
- (NSString *)firstName;
- (NSString *)body;
- (NSString *)log;
- (NSDate *)date;
- (NSString *)emailHeaders;

- (BOOL)public;
- (BOOL)initial;
- (BOOL)isHTML;
- (BOOL)merged;

- (unsigned int)numberOfAttachments;
- (HSRequestAttachment *)attachmentAtIndex:(unsigned int)index;

@end



@interface HSRequestAttachment : HSItem

- (NSString *)filename;
- (NSString *)mimeType;
- (NSURL *)url;
- (NSURL *)privateURL;
- (unsigned int)attachmentID;

@end




