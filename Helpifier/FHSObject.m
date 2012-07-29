//
//  FHSObject.m
//  Helpifier
//
//  Created by Sean Dougall on 12/2/11.
//
//	Copyright (c) 2010-2012 Figure 53 LLC, http://figure53.com
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

#import "FHSObject.h"
#import "NSDictionary+HTTPBodySerialization.h"

@interface FHSObject () <NSURLConnectionDelegate, FFSXMLTreeDelegate>

@property (nonatomic, copy) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *data;

@end

#pragma mark -

@implementation FHSObject

@synthesize url = _url;

@synthesize delegate = _delegate;

@synthesize postData = _postData;

@synthesize lastFetchDate = _lastFetchDate;

@synthesize urlRequest = _urlRequest;

@synthesize urlConnection = _urlConnection;

@synthesize data = _data;

@synthesize xmlTree = _xmlTree;

@synthesize completionHandler = _completionHandler;

@synthesize refreshTimer = _refreshTimer;

- (id)initWithURL:(NSURL *)url delegate:(id <FHSObjectDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.url = url;
        self.delegate = delegate;
        self.postData = nil;
    }
    return self;
}

- (void)fetch
{
    if (self.urlRequest)
    {
        NSLog(@"%@ is skipping this fetch request because another request is already in progress.", self);
        return;
    }
    
    if (!self.url)
    {
        NSLog(@"%@ cannot fetch because it doesn't have a URL.", self);
        return;
    }
    
    self.data = [NSMutableData data];
    
    NSURL *urlWithAuth = [NSURL URLWithString:[NSString stringWithFormat:@"%@&username=%@&password=%@", self.url, self.delegate.username, self.delegate.password]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlWithAuth cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[FFSSettings sharedSettings].timeoutInterval];
    [request setHTTPShouldHandleCookies:NO];
    if ( self.postData )
    {
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[self.postData httpBodyData]];
    }
    self.urlRequest = request;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self startImmediately:YES];
    self.urlConnection = connection;
    
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"FHSDebugConnection"] )
        NSLog( @"Connection started for %@", self );
}

- (void)fetchAfterAppropriateDelay
{
    NSTimeInterval delay = -1;
    if ( [self.delegate respondsToSelector:@selector( timeIntervalBeforeReloadForObject: )] )
        delay = [self.delegate timeIntervalBeforeReloadForObject:self];
    
    if ( delay >= 0.0 )
    {
        if ( _refreshTimer )
            [_refreshTimer invalidate];
        
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector( fetch ) userInfo:nil repeats:NO];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Generic FHSObject at %@", self.url];
}

- (void)finishedParsingXMLTree
{
}

#pragma mark - NSURLConnectionDelegate

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response
{
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"FHSDebugConnection"] )
        NSLog( @"Connection responded for %@", self );
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data
{
	[_data appendData:data];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
    if (connection == self.urlConnection)
    {
        if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"FHSDebugConnection"] )
            NSLog( @"Connection finished for %@", self );
        
        self.urlConnection = nil;
        self.urlRequest = nil;
        if ([self.delegate respondsToSelector:@selector(object:didFinishReceivingData:)])
            [self.delegate object:self didFinishReceivingData:self.data];
        self.lastFetchDate = [NSDate date];
        
        // If we got here from a POST request, we don't want to keep posting that data!
        self.postData = nil;

        /*
         Now parse the XML data.
         HelpSpot sometimes sends stray data before the start of the XML data, which will make
         NSXMLParser barf. This trims everything up to the first '<'.
         */
        NSInteger index = 0;
        char buf;
        NSInteger length = [_data length];
        while (index < length)
        {
            [_data getBytes:&buf range:NSMakeRange(index, 1)];
            if (buf == '<') break;
            index++;
        }
        
        NSMutableData *trimmedData = _data;
        [trimmedData replaceBytesInRange:NSMakeRange(0, index) withBytes:NULL length:0];
        self.xmlTree = [[FFSXMLTree alloc] initWithData:trimmedData delegate:self];   // This will start the XML parsing in the background.
        
        if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"FHSDebugData"] )
            NSLog( @"Received: %@", [NSString stringWithUTF8String:trimmedData.bytes] );
    }
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error
{
    if (connection == self.urlConnection)
    {
        if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"FHSDebugConnection"] )
            NSLog( @"Connection failed for %@", self );
        
        self.urlConnection = nil;
        self.urlRequest = nil;
        if ([self.delegate respondsToSelector:@selector(object:didFailToReceiveDataWithError:)])
            [self.delegate object:self didFailToReceiveDataWithError:error];
    }
}

#pragma mark - FFSXMLTreeDelegate

- (void)treeDidFinishParsing:(FFSXMLTree *)tree
{
    FFSXMLElement *errorElement = [self.xmlTree.rootElement firstChildWithName:@"error"];
    if ( errorElement )
    {
        if ([self.delegate respondsToSelector:@selector(object:didFailToReceiveDataWithError:)])
            [self.delegate object:self didFailToReceiveDataWithError:[NSError errorWithDomain:NSOSStatusErrorDomain code:[errorElement integerForKey:@"id"] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[errorElement stringForKey:@"description"], NSLocalizedFailureReasonErrorKey, nil]]];
        else
            NSLog( @"%@ failed: %@", self, errorElement );
        return;
    }
    
    [self finishedParsingXMLTree];
    if ([self.delegate respondsToSelector:@selector(object:didFinishParsingXMLTree:)])
        [self.delegate object:self didFinishParsingXMLTree:self.xmlTree];
    if ( _completionHandler ) 
        _completionHandler( self );
}

@end
