//
//  ContentTabViewController.m
//  MPControlHub
//
//  Created by Adam Williams on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentTabViewController.h"
#import "Playground.h"
#import "Playlist.h"
#import "PlaylistItem.h"
#import "Content.h"

@interface ContentTabViewController ()
- (void)setupButtons;
@end

@implementation ContentTabViewController

@synthesize playground = _playground;
@synthesize manageButton = _manageButton;
@synthesize playButton = _playButton;
@synthesize enableButton = _enableButton;
@synthesize contentTable = _contentTable;
@synthesize nameColumn = _nameColumn;

- (id)init
{
    self = [super initWithNibName:@"ContentTabViewController" bundle:nil];
    if(self) {
        _playground = [Playground sharedPlayground];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupButtons];    
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setupButtons
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger contentSource = [defaults integerForKey:MPContentSourceKey];
    [self.manageButton setHidden:(contentSource == MPContentSourceRemote)];
    
    [self.playButton setEnabled:NO];
    [self.enableButton setEnabled:NO];
}

- (IBAction)sourceChanged:(id)sender 
{
    [self setupButtons];
}

- (IBAction)playContent:(id)sender 
{
    if(self.playground.running) {
        [self.playground.contentSource demandContentAtIndex:self.contentTable.selectedRow];
    }
}

- (IBAction)toggleEnabled:(id)sender 
{
    NSInteger selectedRow = self.contentTable.selectedRow;
    BOOL enabled = [self.playground.contentSource toggleStateForContentAtIndex:selectedRow];
    if(enabled) {
        self.enableButton.title = NSLocalizedString(@"Disable Content", @"Disable Content");
    }
    else {
        self.enableButton.title = NSLocalizedString(@"Enable Content", @"Enable Content");
    }
    NSIndexSet *rowSet = [NSIndexSet indexSetWithIndex:selectedRow];
    NSIndexSet *colSet = [NSIndexSet indexSetWithIndex:1];
    [self.contentTable reloadDataForRowIndexes:rowSet columnIndexes:colSet];
}

- (IBAction)manageContent:(id)sender 
{

}

#pragma mark - TableView methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.playground.contentSource.currentPlaylist count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    PlaylistItem *item = [self.playground.contentSource.currentPlaylist.playlistItems objectAtIndex:row];
    Content *content = [self.playground.contentSource contentForKey:item.contentKey];
    
    if(tableColumn == self.nameColumn) {
        return content.title;
    }
    else {
        if(item.enabled) {
            return NSLocalizedString(@"Yes", @"Yes");
        }
        else {
            return NSLocalizedString(@"No", @"No");
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger selectedRow = self.contentTable.selectedRow;
    if(selectedRow >= 0) {
        [self.enableButton setEnabled:YES];
        [self.playButton setEnabled:YES];
        PlaylistItem *item = [self.playground.contentSource.currentPlaylist.playlistItems objectAtIndex:selectedRow];
        if(item.enabled) {
            self.enableButton.title = NSLocalizedString(@"Disable Content", @"Disable Content");
        }
        else {
            self.enableButton.title = NSLocalizedString(@"Enable Content", @"Enable Content");
        }
    }
    else {
        [self.playButton setEnabled:NO];
        [self.enableButton setEnabled:NO];
    }
}

@end
