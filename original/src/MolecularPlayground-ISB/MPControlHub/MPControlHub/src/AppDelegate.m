//
//  AppDelegate.m
//  MPControlHub
//
//  Created by Adam Williams on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <ApplicationServices/ApplicationServices.h>
#import "AppDelegate.h"
#import "Playground.h"
#import "LocalContentSource.h"

@implementation AppDelegate

@synthesize playground = _playground;

- (void)dealloc 
{
    [_playground release];
    [_windowController release];
    [super dealloc];
}

- (void)hideCursor
{
    void CGSSetConnectionProperty(int, int, CFStringRef, CFBooleanRef);
    int _CGSDefaultConnection();
    CFStringRef propertyString;
    
    // Hack to make background cursor setting work
    propertyString = CFStringCreateWithCString(NULL, "SetsCursorInBackground", kCFStringEncodingUTF8);
    CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue);
    CFRelease(propertyString);
    // Hide the cursor and wait
    CGDisplayHideCursor(kCGDirectMainDisplay);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
    [self registerDefaults];
    self.playground = [Playground sharedPlayground];
    LocalContentSource *contentSource = [[LocalContentSource alloc] init];
    contentSource.delegate = self.playground;
    self.playground.contentSource = contentSource;
    [contentSource release];
    
    //[self hideCursor];
    
    _windowController = [[HubWindowController alloc] init];
    [_windowController showWindow:self];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:MPLaunchAtStartupKey 
                                               options:NSKeyValueObservingOptionNew 
                                               context:NULL];
    
    BOOL autoLaunched = [[NSUserDefaults standardUserDefaults] boolForKey:MPLaunchAtStartupKey];
    if(autoLaunched) {
        [self addAppAsLoginItem];
        [self.playground start];
        [NSApp hide:self];
    }
    else {
        [self deleteAppFromLoginItems];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"launchAtStartup"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
    BOOL launchAtStartup = [myDefaults boolForKey:MPLaunchAtStartupKey];
    if(launchAtStartup) {
        [self addAppAsLoginItem];
    }
    else {
        [self deleteAppFromLoginItems];
    }
}

- (void)registerDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], MPLaunchAtStartupKey, 
                                 @"../MPJmolApp.app", MPJmolPathKey, 
                                 @"", MPJmolArgsKey, 
                                 [NSNumber numberWithBool:YES], MPMonitorJmolKey,
                                 [NSNumber numberWithInteger:10], MPJmolRestartDelayKey,
                                 [NSNumber numberWithBool:YES], MPMonitorContentKey,
                                 [NSNumber numberWithInteger:10], MPJmolContentIntervalKey,
                                 [NSNumber numberWithBool:YES], MPMonitorCameraKey,
                                 [NSNumber numberWithInteger:10], MPCameraRestartDelayKey,
                                 [NSNumber numberWithInteger:31415], MPServerPortKey,
                                 [NSNumber numberWithInteger:MPCameraSourceKinect], MPCameraSourceKey,
                                 [NSNumber numberWithInteger:MPContentSourceLocal], MPContentSourceKey,
                                 [NSNumber numberWithBool:NO], MPAlternateBannerKey,
                                 @"", MPAlternateBannerTextKey,
                                 [NSNumber numberWithInteger:20], MPAlternateBannerDelayKey,
                                 [NSNumber numberWithBool:YES], MPContentDisableOnErrorKey,
                                 nil];
    [defaults registerDefaults:appDefaults];
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

- (void)deleteAppFromLoginItems
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
