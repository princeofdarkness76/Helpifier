#import "HSPerson.h"

@implementation HSPerson

- (unsigned int)personID
{
	return [[content objectForKey:@"xPerson"] intValue];
}

- (NSString *)fullName
{
	return [content objectForKey:@"fullname"];
}

- (NSString *)firstName
{
	return [content objectForKey:@"sFname"];
}

- (NSString *)lastName
{
	return [content objectForKey:@"sLname"];
}

- (NSString *)username
{
	return [content objectForKey:@"sUsername"];
}

- (NSString *)primaryEmail
{
	return [content objectForKey:@"sEmail"];
}

- (NSString *)secondaryEmail
{
	return [content objectForKey:@"sEmail2"];
}

- (NSString *)sms
{
	return [content objectForKey:@"sSMS"];
}

- (unsigned int)smsServiceID
{
	return [[content objectForKey:@"xSMSService"] intValue];
}

- (NSString *)phone
{
	return [content objectForKey:@"sPhone"];
}

- (NSString *)signature
{
	return [content objectForKey:@"tSignature"];
}

- (NSString *)signatureHTML
{
	return [content objectForKey:@"tSignature_HTML"];
}

- (NSString *)mobileSignature
{
	return [content objectForKey:@"tMobileSignature"];
}

- (BOOL)notifyPrimaryEmail
{
	return [[content objectForKey:@"fNotifyEmail"] intValue];
}

- (BOOL)notifySecondaryEmail
{
	return [[content objectForKey:@"fNotifyEmail2"] intValue];
}

- (BOOL)notifySMS
{
	return [[content objectForKey:@"fNotifySMS"] intValue];
}

- (BOOL)notifySMSUrgent
{
	return [[content objectForKey:@"fNotifySMSUrgent"] intValue];
}

- (unsigned int)photoID
{
	return [[content objectForKey:@"xPersonPhotoId"] intValue];
}

- (BOOL)userType
{
	return [[content objectForKey:@"fUserType"] intValue];
}

- (unsigned int)outOfOffice
{
	return [[content objectForKey:@"xPersonOutOfOffice"] intValue];
}

- (BOOL)notifyOfNewRequest
{
	return [[content objectForKey:@"fNotifyNewRequest"] intValue];
}

- (NSString *)workspace
{
	return [content objectForKey:@"sWorkspaceDefault"];
}

- (BOOL)defaultToPublic
{
	return [[content objectForKey:@"fDefaultToPublic"] intValue];
}

- (BOOL)defaultTTOpen
{
	return [[content objectForKey:@"fDefaultTTOpen"] intValue];
}

- (BOOL)hideWYSIWYG
{
	return [[content objectForKey:@"fHideWysiwyg"] intValue];
}

- (BOOL)hideImages
{
	return [[content objectForKey:@"fHideImages"] intValue];
}

- (unsigned int)requestHistoryLimit
{
	return [[content objectForKey:@"iRequestHistoryLimit"] intValue];
}

- (BOOL)returnToRequest
{
	return [[content objectForKey:@"fReturnToReq"] intValue];
}

- (NSString *)htmlEditor
{
	return [content objectForKey:@"sHTMLEditor"];
}

- (unsigned int)assignedRequests
{
	return [[content objectForKey:@"assigned_requests"] intValue];
}

- (BOOL)deleted
{
	return [[content objectForKey:@"fDeleted"] intValue];
}


@end
