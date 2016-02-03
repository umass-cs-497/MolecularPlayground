//
//  ServerManager.h
//  MPControlHub
//
//  Created by Adam Williams on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleServer.h"
#import "ContentManager.h"

extern NSString *const MPContentStartedNotification;

@interface ServerManager : NSObject {
 @private
    dispatch_source_t timerSource_;
}

@property (retain) ContentManager *contentManager;
@property (copy) NSString *currentContentName;
@property (retain) NSDate *lastScriptTime;
@property (retain) NSDate *lastMoveTime;
@property (retain) NSDate *moveStartTime;
@property (retain) NSDate *lastMotionPing;
@property (assign) NSTimeInterval timeMovingSinceLastScript;
@property (assign) int lastScript;
@property (retain) SimpleServer *remoteServer;
@property (retain) SimpleServer *jmolServer;
@property (retain) SimpleServer *motionServer;
@property (assign, getter = isRemoteActive) BOOL remoteActive;
@property (retain) NSDate *startTime;
@property (copy) NSString *lastError;

- (void)start;
- (void)stop;

- (void)playContent:(int)contentIndex;
- (void)playNextContent;

- (void)sendDebugCommand:(BOOL)debug;
- (void)sendConfigCommand;
- (void)sendJmolQuitCommand;
- (void)sendMotionQuitCommand;
@end
