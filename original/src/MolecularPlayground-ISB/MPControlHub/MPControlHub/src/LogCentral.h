//
//  LogCentral.h
//  MPControlHub
//
//  Created by Adam Williams on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogCentral : NSObject

@property (copy) NSString *logPath;
@property (copy) NSString *lastMessage;

+ (LogCentral *)sharedInstance;
- (void)logError:(NSError *)error;
- (void)logString:(NSString *)message;

@end
