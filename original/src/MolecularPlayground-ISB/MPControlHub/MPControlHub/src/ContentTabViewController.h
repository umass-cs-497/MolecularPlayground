//
//  ContentTabViewController.h
//  MPControlHub
//
//  Created by Adam Williams on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Playground;

@interface ContentTabViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (assign) Playground *playground;
@property (assign) IBOutlet NSButton *manageButton;
@property (assign) IBOutlet NSButton *playButton;
@property (assign) IBOutlet NSButton *enableButton;
@property (assign) IBOutlet NSTableView *contentTable;
@property (assign) IBOutlet NSTableColumn *nameColumn;

@end
