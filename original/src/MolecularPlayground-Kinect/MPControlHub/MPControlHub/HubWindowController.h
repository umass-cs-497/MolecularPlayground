//
//  MPHubWindowController.h
//  MPControlHub
//
//  Created by Adam on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HubWindowController : NSWindowController

@property (assign) IBOutlet NSTabView *tabView;
@property (retain) NSViewController *currentViewController;

- (BOOL)switchViewInTabView:(NSTabView *)tabView withItem:(NSTabViewItem *)item;

@end
