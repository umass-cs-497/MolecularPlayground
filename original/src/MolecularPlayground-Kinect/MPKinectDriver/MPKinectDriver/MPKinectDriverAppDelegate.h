//
//  MPKinectDriverAppDelegate.h
//  MPKinectDriver
//
//  Created by Adam on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenCV/OpenCV.h>
#import "GCDAsyncSocket.h"
#import "libfreenect.h"
#import "ConfigureWindowController.h"

typedef enum {
    kStateDisconnected,
    kStateConnected
} MPConnectionState;

@interface MPKinectDriverAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window_;
    freenect_device *device_;
    
    uint8_t *videoBack_, *videoFront_;
    BOOL videoUpdate_;
    uint16_t *depthBack_, *depthFront_;
    BOOL depthUpdate_;
    
    BOOL halt_;
    
    NSString *status_;
    
    GCDAsyncSocket *inSocket_;
    GCDAsyncSocket *outSocket_;
    dispatch_queue_t socketQueue_;
    MPConnectionState state_;
    
    IplImage *debugImage_;
    BOOL debugging_;
    BOOL configuring_;
    ConfigureWindowController *configureWindowController_;
    
    NSThread *imageThread_;
    NSThread *ioThread_;
}

@property (assign) IBOutlet NSWindow *window;
@property (copy) NSString *status;
@property (assign, getter = isDebugging) BOOL debugging;
@property (retain) ConfigureWindowController *configureWindowController;
@property (assign, getter = isConfiguring) BOOL configuring;

- (uint8_t*)createVideoData;
- (uint16_t*)createDepthData;
- (IplImage *)cvImage;
- (IplImage *)cvDepth;

- (void)safeSetStatus:(NSString *)status;
- (void)doneConfiguring;
- (void)buildAndSaveBG;

@end
