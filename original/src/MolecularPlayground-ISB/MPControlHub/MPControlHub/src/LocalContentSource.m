//
//  LocalContentSource.m
//  MPControlHub
//
//  Created by Adam Williams on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocalContentSource.h"
#import "Playlist.h"
#import "PlaylistItem.h"
#import "Content.h"

NSString *const MPLocalContentPlaylist = @"../Data/Content/Local/playlist.json";
NSString *const MPLocalContentPath = @"/Data/Content/Local/";

@interface LocalContentSource ()
@property (retain) Playlist *currentPlaylist;
@property (retain) Content *currentContent;
@end

@implementation LocalContentSource
{
    int _nextItemIndex;
    NSString *_playlistPath;
    NSString *_contentPath;
}

@synthesize currentPlaylist = _currentPlaylist;
@synthesize currentContent = _currentContent;

- (id)init
{
    self = [super init];
    if(self) {
        NSString *lastPathComponent = [NSString stringWithFormat:@"..%@", MPLocalContentPath];
        _contentPath = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:lastPathComponent] copy];
        _playlistPath = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:MPLocalContentPlaylist] copy];
        [self reset];
    }
    return self;
}

- (void)dealloc
{
    [_currentPlaylist release];
    [_currentContent release];
    [_contentPath release];
    [_playlistPath release];
    [super dealloc];
}

- (Content *)contentForKey:(NSString *)key
{
    NSString *contentMeta = [NSString stringWithFormat:@"%@/meta.json", key];
    NSString *contentPath = [_contentPath stringByAppendingPathComponent:contentMeta];
    Content *content = [[Content alloc] initWithContentsOfFile:contentPath];
    return [content autorelease];
    
}

- (void)requestContent
{    
    NSInteger index = _nextItemIndex;
    int count = [self.currentPlaylist.playlistItems count];
    do {
        _nextItemIndex = ++_nextItemIndex % count;
    } while(_nextItemIndex != index && ![[self.currentPlaylist.playlistItems objectAtIndex:_nextItemIndex] isEnabled]);

    [self demandContentAtIndex:index];
}

- (void)demandContentAtIndex:(NSInteger)index
{
    PlaylistItem *item = [self.currentPlaylist.playlistItems objectAtIndex:index];
    self.currentContent = [self contentForKey:item.contentKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate contentSource:self contentReady:self.currentContent];
    });    
}

- (void)reset
{
    self.currentContent = nil;
    Playlist *playlist = [[Playlist alloc] initWithContentsOfFile:_playlistPath];
    self.currentPlaylist = playlist;
    [playlist release];
    _nextItemIndex = 0;
}

- (NSString *)contentPath
{
    return MPLocalContentPath;
}

- (BOOL)toggleStateForContentAtIndex:(NSInteger)index
{
    PlaylistItem *item = [self.currentPlaylist.playlistItems objectAtIndex:index];
    item.enabled = !item.enabled;
    [self.currentPlaylist writeToFileAtPath:_playlistPath];
    return item.enabled;
}

@end
