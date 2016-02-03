//
//  Content.h
//  MPControlHub
//
//  Created by Adam Williams on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Content : NSObject

@property (assign) int contentID;
@property (assign, getter = isEnabled) BOOL enabled;

@property (copy) NSString *title;
@property (assign, getter = isBannerEnabled) BOOL bannerEnabled;
@property (copy) NSString *bannerText;
@property (copy) NSString *startupScriptName;

- (id)initWithContentID:(int)contentID;
- (void)hydrate;
- (NSDictionary *)contentInfo;
@end
