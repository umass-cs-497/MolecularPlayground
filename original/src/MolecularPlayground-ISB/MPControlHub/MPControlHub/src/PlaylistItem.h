//
//  PlaylistItem.h
//  MPControlHub
//
//  Created by Adam Williams on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaylistItem : NSObject

@property (retain, nonatomic) NSString *contentKey;
@property (assign, nonatomic, getter = isEnabled) BOOL enabled;
@property (assign, nonatomic) int repeatCount;
@property (assign, nonatomic) int minutes;
@property (retain, nonatomic) NSDate *startDate;
@property (retain, nonatomic) NSDate *stopDate;

- (id)initWithDictionary:(NSDictionary *)info;
- (NSDictionary *)dictionary;
@end
