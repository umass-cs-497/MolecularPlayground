//
//  LogCentral.m
//  MPControlHub
//
//  Created by Adam Williams on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LogCentral.h"

@implementation LogCentral

@synthesize logPath = _logPath;
@synthesize lastMessage = _lastMessage;

#pragma mark - Singleton accessor

+ (LogCentral *)sharedInstance
{
    static LogCentral *sharedLogCentral;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogCentral = [[LogCentral alloc] init];
    });
    return sharedLogCentral;
}

#pragma mark - Initializer

- (id)init
{
    self = [super init];
    if(self) {
        _lastMessage = nil;
    }
    return self;
}

- (void)logError:(NSError *)error
{
    if(error) {
        [self logString:[error description]];
    }
}

- (void)logString:(NSString *)message
{
    self.lastMessage = message;
    NSLog(@"%@: %@", [NSDate date], message);
}

@end
