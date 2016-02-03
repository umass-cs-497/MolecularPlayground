//
//  ContentTabViewController.m
//  MPControlHub
//
//  Created by Adam Williams on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentTabViewController.h"
#import "Content.h"

@implementation ContentTabViewController

@synthesize manager = manager_;
@synthesize contentTable = contentTable_;
@synthesize playButton = playButton_;
@synthesize enableButton = enableButton_;
@synthesize nameColumn = nameColumn_;

- (id)initWithServerManager:(ServerManager *)manager {
    
    self = [super initWithNibName:@"ContentTabViewController" bundle:nil];
    if (self) {
        
        manager_ = manager;
        [manager_ retain];
    }    
    return self;
}

- (void)loadView
{
    [super loadView];
    [playButton_ setEnabled:NO];
    [enableButton_ setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(contentStateChanged:) 
                                                 name:MPContentStateChangeNotification 
                                               object:nil];    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [manager_ release];
    [super dealloc];
}

- (void)contentStateChanged:(NSNotification *)notification
{
    [self.contentTable reloadData];
}

#pragma mark -
#pragma mark Table View Data Source methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView 
{
    return [[self.manager.contentManager content] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex 
{
    Content *contentInfo = [[self.manager.contentManager content] objectAtIndex:rowIndex];
    
    if(aTableColumn == self.nameColumn) {
        return contentInfo.title;
    }
    else {
        if(contentInfo.enabled) {
            return @"Yes";
        }
        else {
            return @"No";
        }
    }
}

#pragma mark -
#pragma mark Table View Delegate methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification 
{
    int selectedRow = (int)self.contentTable.selectedRow;
    if(selectedRow >= 0) {
        [enableButton_ setEnabled:YES];
        [playButton_ setEnabled:YES];
        Content *contentInfo = [self.manager.contentManager.content objectAtIndex:selectedRow];
        if([contentInfo isEnabled]) {
            self.enableButton.title = @"Disable Content";
        }
        else {
            self.enableButton.title = @"Enable Content";
        }        
    }
    else {
        [self.enableButton setEnabled:NO];
        [self.playButton setEnabled:NO];
    }

}

- (IBAction)moveUp:(id)sender
{
    NSInteger selectedRow = self.contentTable.selectedRow;
    if(selectedRow == -1) return;
    [self.manager.contentManager moveUpInList:selectedRow];
    [self.contentTable reloadData];
    selectedRow = (selectedRow > 0) ? selectedRow - 1 : selectedRow;
    NSIndexSet *newSelection = [NSIndexSet indexSetWithIndex:selectedRow];
    [self.contentTable selectRowIndexes:newSelection byExtendingSelection:NO];
}

- (IBAction)moveDown:(id)sender
{
    NSInteger selectedRow = self.contentTable.selectedRow;
    if(selectedRow == -1) return;
    [self.manager.contentManager moveDownInList:selectedRow];
    [self.contentTable reloadData];
    selectedRow = (selectedRow < [self.manager.contentManager.content count] - 1) ? selectedRow + 1 : selectedRow;
    NSIndexSet *newSelection = [NSIndexSet indexSetWithIndex:selectedRow];
    [self.contentTable selectRowIndexes:newSelection byExtendingSelection:NO];    
}

- (IBAction)playContent:(id)sender
{
    [self.manager playContent:[self.contentTable selectedRow]];
}

- (IBAction)enableContent:(id)sender
{
    int selectedRow = (int)self.contentTable.selectedRow;
    BOOL enabled = [self.manager.contentManager flipStateForContentIndex:selectedRow];
    if(enabled) {
        self.enableButton.title = @"Disable Content";
    }
    else {
        self.enableButton.title = @"Enable Content";
    }
}

@end
