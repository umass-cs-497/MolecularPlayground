//
//  HubWindowController.m
//  MPControlHub
//
//  Created by Adam Williams on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HubWindowController.h"
#import "GeneralTabViewController.h"
#import "ContentTabViewController.h"
#import "AdvancedTabViewController.h"

@implementation HubWindowController

@synthesize tabView = _tabView;
@synthesize currentViewController = _currentViewController;

- (id)init
{
    self = [super initWithWindowNibName:@"HubWindow"];
    if(self) {
        
    }
    return self;
}

- (void)dealloc
{
    [_tabView release];
    [_currentViewController release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSTabViewItem *selectedItem = [self.tabView selectedTabViewItem];
    [self switchViewInTabView:self.tabView withItem:selectedItem];
}

- (BOOL)switchViewInTabView:(NSTabView *)tabView withItem:(NSTabViewItem *)item
{
    NSViewController *newController = nil;
    
    NSInteger itemIndex = [tabView indexOfTabViewItem:item];
    switch (itemIndex) {
        default:
        case 0:
            newController = [[GeneralTabViewController alloc] init];
            break;
        case 1:
            newController = [[ContentTabViewController alloc] init];
            break;
        case 2:
            newController = [[AdvancedTabViewController alloc] init];
            break;
    }
    
    if(newController != nil) {
        item.view = newController.view;
        self.currentViewController = newController;
        [newController release];
        return YES;
    }
    
    return NO;
}

#pragma mark - NSTabViewDelegate method

- (BOOL)tabView:(NSTabView*)tabView shouldSelectTabViewItem:(NSTabViewItem*)tabViewItem {
    return [self switchViewInTabView:tabView withItem:tabViewItem];
}

@end
