#import "ApplicationDelegate.h"
#import "RequestsController.h"
#import <HelpSpot/HelpSpot.h>

@interface ApplicationDelegate (Private)

- (void) refreshCredentials;

@end


#pragma mark -

@implementation ApplicationDelegate

- (id) init
{
	if (self = [super init])
	{
		self.workspaceInitialized = NO;
	}
	return self;
}

@synthesize requestsController = _requestsController;
@synthesize prefsWindow = _prefsWindow;

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[NSThread detachNewThreadSelector:@selector(refreshCredentials) toTarget:self withObject:nil];
	
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.username" options:NSKeyValueObservingOptionNew context:@selector(refreshCredentials)];
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.password" options:NSKeyValueObservingOptionNew context:@selector(refreshCredentials)];
}

@synthesize workspaceInitialized = _workspaceInitialized;

#pragma mark -
#pragma mark actions

- (IBAction) help: (id) sender
{
	NSRunAlertPanel(@"Help is not available for Helpifier.", @"Come now. That would just be too meta.", @"OK", nil, nil);
}

- (IBAction) showPreferences: (id) sender
{
	[_prefsWindow makeKeyAndOrderFront:sender];
}

- (IBAction) chooseSystemSound: (id) sender
{
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:[sender title] forKey:@"notificationSound"];
    [[NSSound soundNamed:[sender title]] play];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([self respondsToSelector:(SEL)context])
        [self performSelector:(SEL)context];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end


#pragma mark -

@implementation ApplicationDelegate (Private)

- (void) refreshCredentials
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	HSWorkspace *workspace = [HSWorkspace sharedWorkspace];
	[workspace setAuthenticationUsername:[[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"username"] password:[[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"password"] method:HSAuthenticationMethodURL];
	[self willChangeValueForKey:@"workspaceInitialized"];
	self.workspaceInitialized = YES;
	[self didChangeValueForKey:@"workspaceInitialized"];
	[pool release];
}

@end

