//
//  MPHubWindowController.m
//  MPControlHub
//
//  Created by Adam on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HubWindowController.h"
#import "ControlHubAppDelegate.h"
#import "GeneralTabViewController.h"
#import "ContentTabViewController.h"

@implementation HubWindowController

@synthesize tabView = tabView_;
@synthesize currentViewController = currentViewController_;

- (id)init {
    
    self = [super initWithWindowNibName:@"HubWindow"];
    if(self) {
        
    }
    
    return self;
    
}

- (void)dealloc
{
    [tabView_ release];
    [currentViewController_ release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSTabViewItem *selectedItem = [self.tabView selectedTabViewItem];
    [self switchViewInTabView:self.tabView withItem:selectedItem];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (BOOL)switchViewInTabView:(NSTabView *)theTabView withItem:(NSTabViewItem *)item {
    NSViewController *newController = nil;
    
    ControlHubAppDelegate *appDelegate = (ControlHubAppDelegate *)[[NSApplication sharedApplication] delegate];
    
    NSInteger itemIndex = [theTabView indexOfTabViewItem:item];
    switch (itemIndex) {
        case 0:
            newController = [[GeneralTabViewController alloc] initWithServerManager:appDelegate.manager];
        break;
        case 1:
            newController = [[ContentTabViewController alloc] initWithServerManager:appDelegate.manager];
        break;
    }
    
    if(newController != nil) {
        item.view = newController.view;
        self.currentViewController = newController;
        [newController release];
        return YES;
    }
    else {
        return NO;
    }
    
}

- (BOOL)tabView:(NSTabView*)theTabView shouldSelectTabViewItem:(NSTabViewItem*)tabViewItem {
    return [self switchViewInTabView:theTabView withItem:tabViewItem];
}

@end
