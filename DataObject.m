//
//  DataObject.m
//  HelpifierData
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "DataObject.h"
#import "DataRequest.h"
#import "NSData+NSString.h"

@implementation DataObject

@synthesize thisElementString = _thisElementString;
@synthesize delegate = _delegate;
@synthesize isFault = _isFault;
@synthesize errorThrown = _errorThrown;

- (id) init
{
    if (self = [super init])
    {
        _parser = nil;
        _request = nil;
        _isFault = YES;
    }
    return self;
}

- (id) initWithPath: (NSString *) url
{
    if (self = [self init])
    {
        _url = [url retain];
    }
    return self;
}

- (void) dealloc
{
    [_url release];
    _url = nil;
    
    [_request release];
    _request = nil;
    
    [super dealloc];
}

- (void) beginFetch
{
    _errorThrown = NO;
    _request = [[DataRequest alloc] initWithURL:_url delegate:self];
}

- (void) failedToReceiveDataWithError: (NSError *) error
{
    _errorThrown = YES;
    [_delegate dataObjectDidFailFetchWithError:[error localizedDescription]];
}

- (void) finishedReceivingData: (NSData *) data
{
    /*
     HelpSpot sometimes has stray data before the start of the XML data, which will make
     NSXMLParser barf. This trims everything up to the first '<'.
     */
    NSInteger index = 0;
    char buf;
    NSInteger newLength = [data length];
    while (index <  newLength)
    {
        [data getBytes:&buf range:NSMakeRange(index, 1)];
        if (buf == '<') break;
        index++;
    }
    
    NSMutableData *trimmedData = [[data mutableCopy] autorelease];
    [trimmedData replaceBytesInRange:NSMakeRange(0, index) withBytes:NULL length:0];
    
//    NSLog(@"Incoming: %@", [trimmedData UTF8String]);
    
    _parser = [[NSXMLParser alloc] initWithData:trimmedData];
    [_parser setDelegate:self];
    [_parser parse];
    [_parser release];
    _parser = nil;
    [self willChangeValueForKey:@"isFault"];
    _isFault = NO;
    [self didChangeValueForKey:@"isFault"];
    if (!_errorThrown)
        [_delegate dataObjectDidFinishFetch:self];
}

- (void) parser: (NSXMLParser *) parser
foundCharacters: (NSString *) string
{
    [self.thisElementString appendString:string];
}

@end
