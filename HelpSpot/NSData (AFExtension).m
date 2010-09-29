#import "NSData (AFExtension).h"
#import <openssl/bio.h>
#import <openssl/evp.h>
#import <openssl/err.h>

@implementation NSData (AFExtension)

- (NSString *)encodeBase64
{
    return [self encodeBase64WithNewlines:YES];
}

- (NSString *)encodeBase64WithNewlines:(BOOL)encodeWithNewlines
{
    BIO *mem = BIO_new(BIO_s_mem());
    
    BIO *b64 = BIO_new(BIO_f_base64());
    if (!encodeWithNewlines)
        BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    mem = BIO_push(b64, mem);
    
    BIO_write(mem, [self bytes], [self length]);
    BIO_flush(mem);
    
    char *base64Pointer;
    long base64Length = BIO_get_mem_data(mem, &base64Pointer); // this is OK as a long
    NSString *base64String = [[[NSString alloc] initWithBytes:base64Pointer length:base64Length encoding:NSASCIIStringEncoding] autorelease];
	
    BIO_free_all(mem);
    return base64String;
}

@end
