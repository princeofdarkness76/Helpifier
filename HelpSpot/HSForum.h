#import "HSItem.h"

@class HSForumTopic;
@class HSForumPost;

@interface HSForum : HSItem

+ (NSArray *)forums:(NSError **)error;
+ (HSForum *)forumWithID:(unsigned int)forumID error:(NSError **)error;

- (unsigned int)forumID;
- (NSString *)name;
- (unsigned int)order;
- (NSString *)forumDescription;
- (BOOL)closed;
- (NSArray *)topics:(NSError **)error;
- (NSArray *)topicsInRange:(NSRange)range error:(NSError **)error;

- (BOOL)addTopicWithName:(NSString *)name from:(NSString *)poster body:(NSString *)body error:(NSError **)error;

@end


@interface HSForumTopic : HSItem

+ (NSArray *)topicsForQuery:(NSString *)query error:(NSError **)error;

- (unsigned int)topicID;
- (NSString *)name;
- (unsigned int)forumID;
- (NSString *)forumName;
- (BOOL)closed;
- (BOOL)sticky;
- (NSDate *)posted;
- (NSString *)poster;
- (NSString *)link;
- (NSString *)topicDescription;

- (unsigned int)numberOfPosts;
- (NSArray *)posts:(NSError **)error;

- (BOOL)addPostFrom:(NSString *)poster body:(NSString *)body error:(NSError **)error;

@end


@interface HSForumPost : HSItem

- (unsigned int)postID;
- (unsigned int)topicID;
- (NSDate *)posted;
- (NSString *)poster;
- (NSString *)body;
- (NSString *)label;
- (NSURL *)url;

@end
