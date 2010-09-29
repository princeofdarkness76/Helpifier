#import "NSURLRequest (AFExtension).h"

@implementation NSURLRequest (AFExtension)

+ (id)requestWithURL:(NSURL *)url multipartForm:(NSDictionary *)dict
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	NSString *boundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	NSEnumerator *e = [dict keyEnumerator];
	NSMutableData *result = [NSMutableData data];
	NSString *key;
	id value;

	while (key = [e nextObject])
	{
		value = [dict valueForKey:key];
		
		[result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
		{
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, value] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		else if ([value isKindOfClass:[NSURL class]])
		{
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, [[value path] lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[NSData dataWithContentsOfFile:[value path]]];
		}
		else if ([value isKindOfClass:[NSData class]])
		{
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.txt\"\r\n", key, key] dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:value];
		}
		[result appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[result appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPMethod:@"POST"];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:result];
		
	return request;
}

@end
