#import <Cocoa/Cocoa.h>

@interface HSXMLParser : NSObject
{
	NSMutableArray *familyTree;
	NSMutableArray *dictionaryElements, *arrayElements, *ignoredElements, *ignoredContainers;
	NSXMLParser *parser;
	NSMutableString *element;
	
	BOOL lowercaseKeys;
	unsigned int isIgnoring;
	Class rootClass;
	
	id root;
}

+ (HSXMLParser *)parser;

- (id)objectForData:(NSData *)data error:(NSError **)error;

- (NSArray *)dictionaryElements;
- (void)setDictionaryElements:(NSArray *)a;

- (NSArray *)arrayElements;
- (void)setArrayElements:(NSArray *)a;

- (NSArray *)ignoredElements;
- (void)setIgnoredElements:(NSArray *)a;

- (NSArray *)ignoredContainers;
- (void)setIgnoredContainers:(NSArray *)a;

- (Class)rootClass;
- (void)setRootClass:(Class)c;

- (BOOL)makeKeysLowercase;
- (void)setMakeKeysLowercase:(BOOL)u;

- (id)currentParent;
- (void)pushChild:(id)a;
- (void)popChild;
- (void)addChildToCurrentParent:(id)obj forKey:(NSString *)key;

@end
