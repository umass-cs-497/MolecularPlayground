//
//  Playlist.h
//  MPControlHub
//
//  Created by Adam Williams on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Playlist : NSObject

@property (copy, nonatomic) NSString *playlistKey;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSDate *lastUpdate;
@property (copy, nonatomic) NSMutableArray *playlistItems;

- (id)initWithDictionary:(NSDictionary *)info;
- (id)initWithContentsOfFile:(NSString *)path;
- (NSInteger)count;
- (void)writeToFileAtPath:(NSString *)path;

@end
