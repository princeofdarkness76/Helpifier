#import "HSItem.h"

@class HSKnowledgeBookPage;

@interface HSKnowledgeBook : HSItem

+ (NSArray *)books:(NSError **)error;
+ (HSKnowledgeBook *)bookWithID:(unsigned int)bookID error:(NSError **)error;

- (unsigned int)bookID;
- (NSString *)name;
- (unsigned int)order;
- (NSString *)bookDescription;
- (NSArray *)tableOfContentsWithHTML:(BOOL)withHTML error:(NSError **)error;

@end


@interface HSKnowledgeBookChapter : HSItem

- (unsigned int)chapterID;
- (NSString *)title;
- (NSString *)name;
- (unsigned int)order;
- (BOOL)appendix;

- (unsigned int)numberOfPages;
- (HSKnowledgeBookPage *)pageAtIndex:(unsigned int)index;

@end


@interface HSKnowledgeBookPage : HSItem

+ (HSKnowledgeBookPage *)pageWithID:(unsigned int)pageID error:(NSError **)error;
+ (NSArray *)pagesForQuery:(NSString *)query error:(NSError **)error;

- (void)voteIsHelpful:(BOOL)helpful error:(NSError **)error;

- (unsigned int)pageID;
- (NSString *)title;
- (NSString *)name;
- (NSString *)body;
- (unsigned int)order;

- (BOOL)highlight;
- (BOOL)hidden;
- (BOOL)private;
- (unsigned int)helpfulVotes;
- (unsigned int)notHelpfulVotes;
- (NSString *)link;
- (NSString *)pageDescription;
- (NSString *)bookName;
- (unsigned int)chapterID;

@end
