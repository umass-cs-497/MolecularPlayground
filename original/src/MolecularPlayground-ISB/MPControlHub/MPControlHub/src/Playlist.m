//
//  Playlist.m
//  MPControlHub
//
//  Created by Adam Williams on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Playlist.h"
#import "JSONKit.h"
#import "PlaylistItem.h"

@implementation Playlist

@synthesize playlistKey = _playlistKey;
@synthesize title = _title;
@synthesize lastUpdate = _lastUpdate;
@synthesize playlistItems = _playlistItems;

- (id)initWithDictionary:(NSDictionary *)info
{
    self = [super init];
    if(self) {
        _playlistKey = [[info objectForKey:@"key"] copy];
        _title = [[info objectForKey:@"title"] copy];
        double date = [[info objectForKey:@"last_update"] doubleValue];
        _lastUpdate = [[NSDate dateWithTimeIntervalSince1970:date] retain];
        
        NSArray *items = [info objectForKey:@"content"];
        _playlistItems = [[NSMutableArray alloc] initWithCapacity:[items count]];
        for(NSDictionary *itemInfo in items) {
            PlaylistItem *item = [[PlaylistItem alloc] initWithDictionary:itemInfo];
            [_playlistItems addObject:item];
        }
        
        NSLog(@"%@", _playlistItems);

    }
    return self;
}

- (id)initWithContentsOfFile:(NSString *)path
{
    NSError *error = nil;
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path options:0 error:&error];
    [[LogCentral sharedInstance] logError:error];
    
    NSDictionary *contentInfo = [jsonData objectFromJSONDataWithParseOptions:JKParseOptionPermitTextAfterValidJSON error:&error];
    [[LogCentral sharedInstance] logError:error];
    
    [jsonData release];
    return [self initWithDictionary:contentInfo];
}

- (id)init
{
    return [self initWithDictionary:nil];
}

- (void)dealloc
{
    [_playlistKey release];
    [_title release];
    [_lastUpdate release];
    [_playlistItems release];
    
    [super dealloc];
}

- (NSInteger)count
{
    return [self.playlistItems count];
}

- (void)writeToFileAtPath:(NSString *)path
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:0];
    [info setObject:self.playlistKey forKey:@"key"];
    [info setObject:self.title forKey:@"title"];
    [info setObject:[NSNumber numberWithDouble:[self.lastUpdate timeIntervalSince1970]] forKey:@"last_update"];
    NSMutableArray *itemArray = [[NSMutableArray alloc] initWithCapacity:[self.playlistItems count]];
    for (PlaylistItem *item in self.playlistItems) {
        [itemArray addObject:[item dictionary]];
    }
    [info setObject:itemArray forKey:@"content"];
    [itemArray release];
    [[info JSONDataWithOptions:JKSerializeOptionPretty error:NULL] writeToFile:path atomically:NO];
    [info release];
}

@end
