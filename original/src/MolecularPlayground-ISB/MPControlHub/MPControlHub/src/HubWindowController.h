//
//  HubWindowController.h
//  MPControlHub
//
//  Created by Adam Williams on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HubWindowController : NSWindowController

@property (assign) IBOutlet NSTabView *tabView;
@property (retain) NSViewController *currentViewController;

- (BOOL)switchViewInTabView:(NSTabView *)tabView withItem:(NSTabViewItem *)item;

@end
