//
//  Content.m
//  MPControlHub
//
//  Created by Adam Williams on 10/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Content.h"
#import "JSONKit.h"
#import "LogCentral.h"

@implementation Content

@synthesize contentKey = _contentKey;
@synthesize title = _title;
@synthesize bannerText = _bannerText;
@synthesize bannerEnabled = _bannerEnabled;
@synthesize lastUpdate = _lastUpdate;
@synthesize scripts = _scripts;
@synthesize models = _models;

- (id)initWithDictionary:(NSDictionary *)contentInfo
{
    self = [super init];
    if(self) {
        _contentKey = [[contentInfo objectForKey:@"key"] copy];
        _title = [[contentInfo objectForKey:@"title"] copy];
        _bannerEnabled = [[contentInfo objectForKey:@"banner"] boolValue];
        _bannerText = [[contentInfo objectForKey:@"banner_text"] copy];
        
        double date = [[contentInfo objectForKey:@"last_update"] doubleValue];
        _lastUpdate = [[NSDate dateWithTimeIntervalSince1970:date] retain];
        
        _scripts = [[contentInfo objectForKey:@"scripts"] copy];
        _models = [[contentInfo objectForKey:@"models"] copy];
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
    [_contentKey release];
    [_title release];
    [_bannerText release];
    [_lastUpdate release];
    [_scripts release];
    [_models release];
    
    [super dealloc];
}

- (NSString *)description
{
    return self.title;
}

@end
