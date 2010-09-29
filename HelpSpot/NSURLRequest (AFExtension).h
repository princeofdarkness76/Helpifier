@interface NSURLRequest (AFExtension)

+ (id)requestWithURL:(NSURL *)url multipartForm:(NSDictionary *)dict;

@end
