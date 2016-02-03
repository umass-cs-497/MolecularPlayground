//
//  ContentSource.m
//  MPControlHub
//
//  Created by Adam Williams on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentSource.h"

@implementation ContentSource

@synthesize syncEnabled = _syncEnabled;
@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    if(self) {
        _syncEnabled = NO;
    }
    return self;
}

- (void)requestContent {}
- (void)demandContentAtIndex:(NSInteger)index {}
- (Playlist *)currentPlaylist { return nil; }
- (Content *)currentContent { return nil; }
- (void)reset {}
- (Content *)contentForKey:(NSString *)key { return nil; }
- (NSString *)contentPath { return @""; }
- (BOOL)toggleStateForContentAtIndex:(NSInteger)index { return NO; }

@end
