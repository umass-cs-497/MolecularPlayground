//
//  ContentSource.h
//  MPControlHub
//
//  Created by Adam Williams on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Content;
@class Playlist;

@protocol ContentSourceDelegate;

@interface ContentSource : NSObject

@property (assign, getter = isSyncEnabled) BOOL syncEnabled;
@property (assign) id<ContentSourceDelegate> delegate;
@property (readonly) Playlist *currentPlaylist;
@property (readonly) Content *currentContent;

- (void)requestContent;
- (void)demandContentAtIndex:(NSInteger)index;
- (void)reset;
- (NSString *)contentPath;
- (Content *)contentForKey:(NSString *)key;
- (BOOL)toggleStateForContentAtIndex:(NSInteger)index;

@end

@protocol ContentSourceDelegate <NSObject>
- (void)contentSource:(ContentSource *)contentSource contentReady:(Content *)content;
@end

