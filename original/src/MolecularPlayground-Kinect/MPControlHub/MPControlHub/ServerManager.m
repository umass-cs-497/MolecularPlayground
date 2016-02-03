//
//  ServerManager.m
//  MPControlHub
//
//  Created by Adam Williams on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerManager.h"
#import "ControlHubAppDelegate.h"
#import "JSONKit.h"

NSString *const MPContentStartedNotification = @"MPContentStartedNotification";

@interface ServerManager ()
- (void)processRemoteMsg:(NSDictionary *)msg;
- (void)processJmolMsg:(NSDictionary *)msg;
- (void)processMotionMsg:(NSDictionary *)msg;
@end

@implementation ServerManager

@synthesize contentManager = contentManager_;
@synthesize lastScriptTime = lastScriptTime_;
@synthesize lastMoveTime = lastMoveTime_;
@synthesize moveStartTime = moveStartTime_;
@synthesize lastMotionPing = lastMotionPing_;
@synthesize timeMovingSinceLastScript = timeMovingSinceLastScript_;
@synthesize remoteServer = remoteServer_;
@synthesize jmolServer = jmolServer_;
@synthesize motionServer = motionServer_;
@synthesize remoteActive = remoteActive_;
@synthesize startTime = startTime_;
@synthesize lastError = lastError_;
@synthesize currentContentName = currentContentName_;
@synthesize lastScript = lastScript_;

- (id)init
{
    self = [super init];
    if (self) {
        remoteServer_ = [[SimpleServer alloc] initWithMagicWord:@"iOSRemote"];
        remoteServer_.delegate = self;
        remoteServer_.port = 31415;
        jmolServer_ = [[SimpleServer alloc] initWithMagicWord:@"JmolApp"];
        jmolServer_.delegate = self;
        jmolServer_.port = 31416;
        motionServer_ = [[SimpleServer alloc] initWithMagicWord:@"KinectDriver"];
        motionServer_.delegate = self;
        motionServer_.port = 31417;
        
        remoteActive_ = NO;
        
        [jmolServer_ addObserver:self forKeyPath:@"connected" options:NSKeyValueObservingOptionOld context:NULL];
        
        contentManager_ = [[ContentManager alloc] init];
        
        lastError_ = @"None";
        startTime_ = [NSDate date];
        [startTime_ retain];
        
        [[NSUserDefaults standardUserDefaults] addObserver:self 
                                                forKeyPath:@"allowsRemote" 
                                                   options:NSKeyValueObservingOptionNew 
                                                   context:NULL];
        currentContentName_ = @"Nothing";
        moveStartTime_ = nil;
        lastMoveTime_ = nil;
        lastScriptTime_ = nil;
        lastMotionPing_ = nil;
        timeMovingSinceLastScript_ = 0;
        lastScript_ = 0;
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(object == self.jmolServer && [keyPath isEqualToString:@"connected"]) {
            if(self.jmolServer.connected) {
                [self playNextContent];
            }
        }
        else if(object == self.motionServer && [keyPath isEqualToString:@"connected"]) {
            
        }
        else if([keyPath isEqualToString:@"allowsRemote"]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL allowsRemote = [defaults boolForKey:@"allowsRemote"];
            if(allowsRemote) {
                [self.remoteServer start];
            }
            else {
                [self.remoteServer stop];
            }
        }
    });
}

- (void)start
{
    [self.jmolServer start];
    [self.motionServer start];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL allowsRemote = [defaults boolForKey:@"allowsRemote"];
    if(allowsRemote) {
        [self.remoteServer start];
    }
    else {
        [self.remoteServer stop];
    }
        
    uint64_t interval = 5000000000;
    timerSource_ = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timerSource_, dispatch_time(DISPATCH_TIME_NOW, 20000000000), interval, 10000);
    
    void (^statusCheck)(void) =  ^ {
        ControlHubAppDelegate *appDelegate = (ControlHubAppDelegate *)[[NSApplication sharedApplication] delegate];
        NSDate *now = [NSDate date];
        NSTimeInterval timeSinceLastScriptLoad = [now timeIntervalSinceDate:self.lastScriptTime];
        NSTimeInterval timeSinceLastMove = [now timeIntervalSinceDate:self.lastMoveTime];
        NSTimeInterval timeSinceMoveStarted = [now timeIntervalSinceDate:self.moveStartTime];
        NSTimeInterval timeSinceLastMotionPing = [now timeIntervalSinceDate:self.lastMotionPing];
        
        if(self.moveStartTime == nil) {
            NSLog(@"Checking Jmol...%f %f", timeSinceLastScriptLoad, self.timeMovingSinceLastScript);
            if(timeSinceLastScriptLoad - self.timeMovingSinceLastScript > 360) {
                if([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.molecularplayground.MPJmolApp"] count] > 0) {
                    [self sendJmolQuitCommand];
                    [appDelegate killJmol];
                    NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
                    if([myDefaults boolForKey:@"disableContentOnError"]) {
                        [self.contentManager flipStateForContentIndex:self.lastScript];
                    }
                    self.lastError = @"Jmol unresponsive...rebooting.";
                    return;
                }
            }
        }
        else {
            if(timeSinceLastMove > 20) {
                self.moveStartTime = nil;
                self.lastMoveTime = nil;
                self.timeMovingSinceLastScript += timeSinceMoveStarted;
            }
        }

        NSLog(@"Checking Kinect...%f", timeSinceLastMotionPing);
        if(self.lastMotionPing != nil && timeSinceLastMotionPing > 60) {
            if([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.molecularplayground.MPKinectDriver"] count] > 0) {
                [self sendMotionQuitCommand];
                [appDelegate killKinect];
                self.lastError = @"Kinect unresponsive...rebooting.";
                self.lastMotionPing = nil;
                return;
            }            
        }
        
        if([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.molecularplayground.MPJmolApp"] count] == 0) {
            [appDelegate startJmol];
        }
        
        if([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.molecularplayground.MPKinectDriver"] count] == 0) {
            [appDelegate startKinect];
        }
    };
    
    dispatch_source_set_event_handler(timerSource_, statusCheck);
    dispatch_resume(timerSource_);
}

- (void)stop
{
    if(timerSource_ != NULL) {
        dispatch_source_cancel(timerSource_);
        dispatch_release(timerSource_);
    }
    
    timerSource_ = NULL;
    
    [self.remoteServer stop];
    [self.jmolServer stop];
    [self.motionServer stop];
}

- (void)dealloc
{
    [jmolServer_ removeObserver:self forKeyPath:@"connected"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"allowsRemote"];
    
    [currentContentName_ release];
    [contentManager_ release];
    [remoteServer_ release];
    [jmolServer_ release];
    [motionServer_ release];
    [lastScriptTime_ release];
    [lastMoveTime_ release];
    [moveStartTime_ release];
    [lastMotionPing_ release];
    [startTime_ release];
    [lastError_ release];
}

- (void)server:(SimpleServer *)server receivedMessage:(NSDictionary *)msg
{
    if(server == self.remoteServer) {
        [self processRemoteMsg:msg];
    }
    else if(server == self.jmolServer) {
        [self processJmolMsg:msg];
    }
    else if(server == self.motionServer) {
        [self processMotionMsg:msg];
    }
}

- (void)processJmolMsg:(NSDictionary *)msg
{
    NSString *type = [msg valueForKey:@"type"];
    if([type isEqualToString:@"script"]) {
        [self playNextContent];
    }    
}

- (void)processMotionMsg:(NSDictionary *)msg
{
    NSString *type = [msg valueForKey:@"type"];
    
    if([type isEqualToString:@"move"]) {
        [self.jmolServer sendDictionary:msg];
        if(self.moveStartTime == nil) {
            self.moveStartTime = [NSDate date];
        }
        else {
            self.lastMoveTime = [NSDate date];
        }
    }
    self.lastMotionPing = [NSDate date];
}

- (void)processRemoteMsg:(NSDictionary *)msg
{
    NSString *type = [msg valueForKey:@"type"];
    
    if([type isEqualToString:@"move"]) {
        [self.jmolServer sendDictionary:msg];
    }
    else if([type isEqualToString:@"control"]) {
        self.remoteActive = YES;
        
        NSDictionary *response = [[NSDictionary alloc] initWithObjectsAndKeys:@"OK", @"control", nil];
        [self.remoteServer sendDictionary:response];
        [response release];
    }
    else if([type isEqualToString:@"release"]) {
        self.remoteActive = NO;
        
        NSDictionary *response = [[NSDictionary alloc] initWithObjectsAndKeys:@"OK", @"release", nil];
        [self.remoteServer sendDictionary:response];
        [response release];        
    }
}

- (void)playNextContent
{
    [self playContent:[self.contentManager nextContent]];
}

- (void)playContent:(int)contentIndex
{
    int contentID = [self.contentManager contentIDAtIndex:contentIndex];
    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:@"content", @"type", [NSNumber numberWithInt:contentID], @"id",nil];
    [self.jmolServer sendDictionary:message];
    [message release];
    
    NSDictionary *userInfo = [self.contentManager infoForContentIndex:contentIndex];
    self.currentContentName = [userInfo objectForKey:@"title"];
    self.lastScriptTime = [NSDate date];
    self.timeMovingSinceLastScript = 0;
    self.lastScript = contentIndex;
}

- (void)sendDebugCommand:(BOOL)debug
{
    NSString *status = (debug) ? @"on" : @"off";
    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:@"debug", @"type",status, @"status", nil];
    [self.motionServer sendDictionary:message];
    [message release];
}

- (void)sendConfigCommand
{
    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:@"configure", @"type",nil];
    [self.motionServer sendDictionary:message];
    [message release];    
}

- (void)sendJmolQuitCommand
{
    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:@"quit", @"type",nil];
    [self.jmolServer sendDictionary:message];
    [message release];    
}

- (void)sendMotionQuitCommand
{
    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:@"quit", @"type",nil];
    [self.motionServer sendDictionary:message];
    [message release];    
}


@end
