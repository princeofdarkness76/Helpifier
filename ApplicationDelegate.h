#import <HelpSpot/HelpSpot.h>

@class RequestsController;

@interface ApplicationDelegate : NSObject
{
	RequestsController      *_requestsController;
	NSWindow                *_prefsWindow;
	BOOL                     _workspaceInitialized;
}

@property (assign) IBOutlet RequestsController *requestsController;
@property (assign) IBOutlet NSWindow *prefsWindow;
@property (readonly) BOOL workspaceInitialized;

- (IBAction) help: (id) sender;
- (IBAction) showPreferences: (id) sender;

@end
