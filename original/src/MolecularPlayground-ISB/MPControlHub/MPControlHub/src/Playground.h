//
//  Playground.h
//  MPControlHub
//
//  Created by Adam Williams on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Monitor.h"
#import "ServerController.h"
#import "ContentSource.h"

@interface Playground : NSObject <ServerControllerDelegate, ContentSourceDelegate> {
    NSTask *_jmolTask;
    NSTask *_cameraTask;
}

@property (readonly, nonatomic) ServerController *server;
@property (retain, nonatomic) ContentSource *contentSource;
@property (readonly, nonatomic) Monitor *monitor;

@property (assign, nonatomic, getter = isRunning) BOOL running;
@property (copy, nonatomic) NSString *jmolStatus;
@property (copy, nonatomic) NSString *cameraStatus;
@property (copy, nonatomic) NSString *runningStatus;

+ (Playground *)sharedPlayground;
- (void)start;
- (void)stop;
- (void)quit;
- (void)startJmol;
- (void)killJmol;

@end
