//
//  Content.m
//  MPControlHub
//
//  Created by Adam Williams on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Content.h"
#import "ContentManager.h"
#import "JSONKit.h"

@implementation Content

@synthesize contentID = contentID_;
@synthesize enabled = enabled_;

@synthesize title = title_;
@synthesize bannerEnabled = bannerEnabled_;
@synthesize bannerText = bannerText_;
@synthesize startupScriptName = startupScriptName_;

- (id)initWithContentID:(int)contentID
{
    self = [super init];
    if(self) {
        contentID_ = contentID;
    }
    return self;
}

- (void)hydrate
{
    NSString *infoPath = [NSString stringWithFormat:@"%@/%d/%d.json", [ContentManager cacheRootPath], self.contentID, self.contentID];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:infoPath];
    NSError *error = nil;
    NSDictionary *contentInfo = [jsonData objectFromJSONDataWithParseOptions:JKParseOptionPermitTextAfterValidJSON error:&error];
    if(error != nil)
        NSLog(@"%@", [error description]);
    [jsonData release];
    
    self.title = [contentInfo valueForKey:@"title"];
    self.bannerEnabled = [[contentInfo valueForKey:@"banner"] boolValue];
    self.bannerText = [contentInfo valueForKey:@"banner_text"];
    self.startupScriptName = [contentInfo valueForKey:@"startup_script"];   
}

- (void)dealloc
{
    [title_ release];
    [bannerText_ release];
    [startupScriptName_ release];
}

- (NSDictionary *)contentInfo
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:4];
    [info setValue:self.title forKey:@"title"];
    [info setValue:[NSNumber numberWithBool:self.bannerEnabled] forKey:@"banner"];
    [info setValue:self.bannerText forKey:@"banner_text"];
    [info setValue:self.startupScriptName forKey:@"startup_script"];
    
    return [info autorelease];
}

@end
