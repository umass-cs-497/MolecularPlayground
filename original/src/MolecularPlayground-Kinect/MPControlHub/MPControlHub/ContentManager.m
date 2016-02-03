//
//  ContentManager.m
//  MPControlHub
//
//  Created by Adam Williams on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentManager.h"
#import "Content.h"
#import "JSONKit.h"

NSString *const kContentCacheIndex = @"../Content-Cache/index.json";
NSString *const kContentCacheRoot = @"../Content-Cache/";

NSString *const MPContentStateChangeNotification = @"MPContentStateChangeNotification";

@interface ContentManager ()
- (void)findNextEnabledContent;
@end


@implementation ContentManager

@synthesize content = content_;

- (id)init
{
    self = [super init];
    if (self) {
        NSString *indexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kContentCacheIndex];
        NSData *indexData = [[NSData alloc] initWithContentsOfFile:indexPath];
        NSDictionary *indexInfo = [indexData objectFromJSONData];
        NSArray *contentList = [indexInfo valueForKey:@"content"];
        NSMutableArray *tempContent = [[NSMutableArray alloc] initWithCapacity:[contentList count]];
        
        for(NSDictionary *info in contentList) {
            Content *newContent = [[Content alloc] initWithContentID:[[info valueForKey:@"id"] intValue]];
            [newContent hydrate];
            newContent.enabled = [[info valueForKey:@"enabled"] isEqualToString:@"yes"];
            [tempContent addObject:newContent];
        }
        content_ = tempContent;
        
        currentContentID_ = -1;
    }
    
    return self;
}

+ (NSString *)cacheRootPath
{
    NSString *cachePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kContentCacheRoot];
    return cachePath;
}

- (void)findNextEnabledContent
{
    int startIndex = currentContentID_;
    BOOL enabled = NO;
    while(!enabled) {
        currentContentID_ = (currentContentID_ + 1) % (int)[self.content count];
        Content *item = [self.content objectAtIndex:currentContentID_];
        enabled = item.enabled;
        if(currentContentID_ == startIndex) break;
    }
}

- (int)nextContent
{
    [self findNextEnabledContent];   
    return currentContentID_;
}

- (NSDictionary *)infoForContentIndex:(int)index
{
    return [[self.content objectAtIndex:index] contentInfo];
}

- (BOOL)flipStateForContentIndex:(int)index
{
    Content *item = [self.content objectAtIndex:index];
    item.enabled = !item.enabled;
    [[NSNotificationCenter defaultCenter] postNotificationName:MPContentStateChangeNotification object:item];
    return item.enabled;
}

- (int)contentIDAtIndex:(int)index 
{
    return [[self.content objectAtIndex:index] contentID];
}

- (void)moveUpInList:(NSUInteger)index
{
    if(index < 1 || index >= [self.content count]) return;
    [self.content exchangeObjectAtIndex:index withObjectAtIndex:index-1];
}

- (void)moveDownInList:(NSUInteger)index
{
    if(index >= [self.content count] - 1) return;
    [self.content exchangeObjectAtIndex:index withObjectAtIndex:index+1];
}

- (void)saveIndex
{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:[self.content count]];
    for(Content *item in self.content) {
        NSNumber *contentID = [NSNumber numberWithInt:item.contentID];
        NSString *enabled = ([item isEnabled]) ? @"yes" : @"no";
        NSDictionary *contentInfo = [NSDictionary dictionaryWithObjectsAndKeys:contentID, @"id", enabled, @"enabled", nil];
        [list addObject:contentInfo];
    }
    NSDictionary *index = [NSDictionary dictionaryWithObject:list forKey:@"content"];
    NSData *jsonData = [index JSONData];
    NSString *indexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kContentCacheIndex];
    [jsonData writeToFile:indexPath atomically:NO];
}
@end
