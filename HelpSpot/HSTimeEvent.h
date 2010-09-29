#import "HSItem.h"

@interface HSTimeEventQuery : HSItem
	
- (void)setStartDate:(NSDate *)start;
- (void)setEndDate:(NSDate *)end;
- (void)setUserID:(unsigned int)userID;
- (void)setFirstName:(NSString *)name;
- (void)setLastName:(NSString *)name;
- (void)setEmail:(NSString *)email;
- (void)setMailbox:(unsigned int)mailboxID;
- (void)setCategoryID:(unsigned int)catID;
- (void)setValue:(NSString *)value forCustomField:(unsigned int)field;
- (void)setIsOpen:(BOOL)o;
- (void)setStatus:(unsigned int)x;
- (void)setUrgent:(BOOL)u;
- (void)setOpenedVia:(NSString *)o;
- (void)setAssignedTo:(NSString *)a;
- (void)setOpenedBy:(NSString *)a;

@end

@interface HSTimeEvent : HSItem

+ (NSArray *)timeEventsForQuery:(HSTimeEventQuery *)query error:(NSError **)error;

- (BOOL)delete:(NSError **)error;

- (unsigned int)eventID;
- (unsigned int)requestID;
- (NSString *)fullName;
- (NSString *)eventDescription;
- (unsigned int)length;
- (NSDate *)date;
- (NSDate *)dateAdded;

@end
