//
//  MPControlHubAppDelegate.m
//  MPControlHub
//
//  Created by Adam Williams on 7/8/11.
//

#import "ControlHubAppDelegate.h"
#import "HubWindowController.h"

NSString *const kKinectDriverPath = @"../MPKinectDriver.app";
NSString *const kJmolPath = @"../MPJmolApp.app";

@interface ControlHubAppDelegate ()
- (void)addAppAsLoginItem;
- (void)deleteAppFromLoginItem;
@end

@implementation ControlHubAppDelegate

@synthesize manager = manager_;
@synthesize started = started_;

- (id)init 
{
    self = [super init];
    if(self) {
        
        manager_ = [[ServerManager alloc] init];
        started_ = NO;
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{    
    windowController_ = [[HubWindowController alloc] init];
    [windowController_ showWindow:self];
    
    NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                 @"allowsRemote", [NSNumber numberWithBool:NO], @"disableContentOnError", 
                                 [NSNumber numberWithBool:YES], @"launchAtStartup", nil];
    [myDefaults registerDefaults:appDefaults];
    
    [myDefaults addObserver:self 
                 forKeyPath:@"launchAtStartup" 
                    options:NSKeyValueObservingOptionNew 
                    context:NULL];
    
    BOOL launchAtStartup = [myDefaults boolForKey:@"launchAtStartup"];
    if(launchAtStartup) {
        [self addAppAsLoginItem];
    }
    else {
        [self deleteAppFromLoginItem];
    }
    
    [self startEverything];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self.manager.contentManager saveIndex];
    NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
    [myDefaults removeObserver:self forKeyPath:@"launchAtStartup"];
}

- (void)dealloc 
{
    [manager_ release];
    [windowController_ release];
    [super dealloc];
}

- (void)startEverything
{
    self.started = YES;
    [self.manager start];
    [self startJmol];
    [self startKinect];
}

- (void)startJmol
{
    NSString *jmolPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kJmolPath];    
    NSTask *jmolTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObject:jmolPath]]; 
}

- (void)startKinect
{
    NSString *kinectPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kKinectDriverPath];    
    NSTask *kinectTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObject:kinectPath]];
}

- (void)killJmol
{
    [[NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.molecularplayground.MPJmolApp"] makeObjectsPerformSelector:@selector(terminate)];
}

- (void)killKinect
{
    [[NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.molecularplayground.MPKinectDriver"] makeObjectsPerformSelector:@selector(terminate)];    
}

- (void)stopEverything
{
    self.started = NO;
    [self.manager sendMotionQuitCommand];
    [self.manager sendJmolQuitCommand];
    [self.manager stop];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
    BOOL launchAtStartup = [myDefaults boolForKey:@"launchAtStartup"];
    if(launchAtStartup) {
        [self addAppAsLoginItem];
    }
    else {
        [self deleteAppFromLoginItem];
    }
}

- (void)addAppAsLoginItem
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}	
	CFRelease(loginItems);
}

- (void)deleteAppFromLoginItem
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i = 0; i < [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
		[loginItemsArray release];
	}
}
@end
