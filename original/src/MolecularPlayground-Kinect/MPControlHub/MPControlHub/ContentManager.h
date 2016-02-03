//
//  ContentManager.h
//  MPControlHub
//
//  Created by Adam Williams on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const MPContentStateChangeNotification;

@interface ContentManager : NSObject {
    int currentContentID_;
}

@property (copy) NSMutableArray *content;

+ (NSString *)cacheRootPath;
- (int)nextContent;
- (NSDictionary *)infoForContentIndex:(int)index;
- (int)contentIDAtIndex:(int)index;
- (BOOL)flipStateForContentIndex:(int)index;
- (void)saveIndex;
- (void)moveUpInList:(NSUInteger)index;
- (void)moveDownInList:(NSUInteger)index;
@end
