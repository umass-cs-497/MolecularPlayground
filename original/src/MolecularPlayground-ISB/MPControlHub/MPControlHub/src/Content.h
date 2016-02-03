//
//  Content.h
//  MPControlHub
//
//  Created by Adam Williams on 10/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Content : NSObject
                                                                        
@property (copy, nonatomic) NSString *contentKey;                           // must be unique
@property (copy, nonatomic) NSString *title;                                // display name
@property (copy, nonatomic) NSString *bannerText;                           // Jmol banner text
@property (assign, nonatomic, getter = isBannerEnabled) BOOL bannerEnabled; // should there be a banner?
@property (copy, nonatomic) NSDate *lastUpdate;                             // (optional) last modified date for syncing

@property (copy, nonatomic) NSArray *scripts;                               // array of dictionaries of form {filename,modified date,isStartup}
@property (copy, nonatomic) NSArray *models;                                // array of dictionaries of form {filename,modified date}
                                                                        
- (id)initWithDictionary:(NSDictionary *)contentInfo;
- (id)initWithContentsOfFile:(NSString *)path;

@end
