//
//  DataRequest.m
//  Helpifier
//
//  Created by Sean Dougall on 5/11/10.
//
//	Copyright (c) 2010-2011 Figure 53 LLC, http://figure53.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
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
        _httpMethod = [@"GET" retain];
        _postData = nil;
		
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&username=%@&password=%@", _url, AppDelegate.username, AppDelegate.password]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kTimeoutInterval];

/*		NSString *authPair = [NSString stringWithFormat:@"%@:%@", AppDelegate.username, AppDelegate.password];
        NSString *authToken = [[authPair encodeBase64] retain];

		[request addValue:[NSString stringWithFormat:@"Basic %@", authToken] forHTTPHeaderField:@"Authorization"];*/

		[request setHTTPShouldHandleCookies:NO];
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
#pragma unused(connection)
		[request release];
	}
	return self;
}

- (id) initWithURL: (NSString *) url postData: (NSData *) postData delegate: (DataObject *) newDelegate
{
	if (self = [super init])
	{
		_data = [[NSMutableData data] retain];
		_url = [url retain];
		_delegate = [newDelegate retain];
        _httpMethod = [@"POST" retain];
        _postData = [postData retain];
		
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&username=%@&password=%@", _url, AppDelegate.username, AppDelegate.password]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kTimeoutInterval];
        
        /*		NSString *authPair = [NSString stringWithFormat:@"%@:%@", AppDelegate.username, AppDelegate.password];
         NSString *authToken = [[authPair encodeBase64] retain];
         
         [request addValue:[NSString stringWithFormat:@"Basic %@", authToken] forHTTPHeaderField:@"Authorization"];*/
        
		[request setHTTPShouldHandleCookies:NO];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:_postData];
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
#pragma unused(connection)
		[request release];
	}
	return self;
}

- (void) dealloc
{
    [_postData release];
    _postData = nil;
    
    [_httpMethod release];
    _httpMethod = nil;
    
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
