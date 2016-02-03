//
//  PlaylistItem.m
//  MPControlHub
//
//  Created by Adam Williams on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaylistItem.h"

@implementation PlaylistItem

@synthesize contentKey = _contentKey;
@synthesize enabled = _enabled;
@synthesize repeatCount = _repeatCount;
@synthesize minutes = _minutes;
@synthesize startDate = _startDate;
@synthesize stopDate = _stopDate;

- (id)initWithDictionary:(NSDictionary *)info
{
    self = [super init];
    if(self) {
        _contentKey = [[info objectForKey:@"key"] copy];
        _enabled = [[info objectForKey:@"enabled"] isEqualToString:@"yes"];
        _repeatCount = [[info objectForKey:@"repeat"] intValue];
        _minutes = [[info objectForKey:@"timer"] intValue];
        double clockIn = [[info objectForKey:@"clock_in"] doubleValue];
        double clockOut = [[info objectForKey:@"clock_out"] doubleValue];
        _startDate = [[NSDate dateWithTimeIntervalSince1970:clockIn] retain];
        _stopDate = [[NSDate dateWithTimeIntervalSince1970:clockOut] retain];
    }
    return self;
}

- (void)dealloc
{
    [_contentKey release];
    [_startDate release];
    [_stopDate release];
    
    [super dealloc];
}

- (NSString *)description
{
    return self.contentKey;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:0];
    [info setObject:self.contentKey forKey:@"key"];
    NSString *enabledText = (self.enabled) ? @"yes" : @"no";
    [info setObject:enabledText forKey:@"enabled"];
    [info setObject:[NSNumber numberWithInteger:self.repeatCount] forKey:@"repeat"];
    [info setObject:[NSNumber numberWithInteger:self.minutes] forKey:@"timed"];
    [info setObject:[NSNumber numberWithDouble:[self.startDate timeIntervalSince1970]] forKey:@"clock_in"];
    [info setObject:[NSNumber numberWithDouble:[self.stopDate timeIntervalSince1970]] forKey:@"clock_out"];
    return [info autorelease];
}

@end
