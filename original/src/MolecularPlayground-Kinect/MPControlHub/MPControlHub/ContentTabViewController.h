//
//  ContentTabViewController.h
//  MPControlHub
//
//  Created by Adam Williams on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerManager.h"

@interface ContentTabViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (retain) ServerManager *manager;
@property (assign) IBOutlet NSTableView *contentTable;
@property (assign) IBOutlet NSButton *playButton;
@property (assign) IBOutlet NSButton *enableButton;
@property (assign) IBOutlet NSTableColumn *nameColumn;

- (id)initWithServerManager:(ServerManager *)manager;

- (IBAction)playContent:(id)sender;
- (IBAction)enableContent:(id)sender;
- (IBAction)moveUp:(id)sender;
- (IBAction)moveDown:(id)sender;
@end
