//
//  DataRequest.m
//  ChromaData
//
//  Created by Sean Dougall on 5/11/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "DataRequest.h"
#import "HelpifierAppDelegate.h"
#import "NSString+Base64.h"

@implementation DataRequest

- (id) initWithURL: (NSString *) url delegate: (DataObject *) newDelegate
{
	if (self = [super init])
	{
		_data = [[NSMutableData data] retain];
		_url = [url retain];
		_delegate = [newDelegate retain];
		
		NSString *authToken;
		
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kTimeoutInterval];
		NSString *authPair;

        authPair = [NSString stringWithFormat:@"%@:%@", AppDelegate.username, AppDelegate.password];
        authToken = [[authPair encodeBase64] retain];

		[request setHTTPShouldHandleCookies:NO];
		[request addValue:[NSString stringWithFormat:@"Basic %@", authToken] forHTTPHeaderField:@"Authorization"];
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
#pragma unused(connection)
		[request release];
	}
	return self;
}

- (void) dealloc
{
	[_data release];
	_data = nil;
	
	[_url release];
	_url = nil;
	
	[_delegate release];
	_delegate = nil;
	
	[super dealloc];
}

@synthesize delegate = _delegate;


#pragma mark -
#pragma mark NSURLConnection delegate stuff

- (BOOL) connection: (NSURLConnection *) connection canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *) protectionSpace
{
	if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
		return YES;
	
	if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
		return YES;
	
	return NO;
}

- (void) connection: (NSURLConnection *) connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge
{
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
		[challenge.sender useCredential:[NSURLCredential credentialWithUser:AppDelegate.username 
																   password:AppDelegate.password 
																persistence:NSURLCredentialPersistenceForSession]
                                                 forAuthenticationChallenge:challenge];
	}
	
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	}
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response
{
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data
{
	[_data appendData:data];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
	[connection release];
	connection = nil;
	
	[_delegate finishedReceivingData:_data];
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error
{
	[_delegate failedToReceiveDataWithError:error];
	
	[connection release];
	connection = nil;
}

@end
