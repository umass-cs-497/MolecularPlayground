//
//  MotionSource.h
//  MPMotionDriver
//
//  Created by Adam Williams on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenCV.h"
#import "DebugWindowController.h"
#import "ConfigureWindowController.h"

@protocol MotionSourceDelegate;

@interface MotionSource : NSObject <MPImageSource, NSWindowDelegate>
{    
    CvSize _frameSize;
    BOOL _halt;
    ConfigureWindowController *_configureWindowController;
}

@property (assign, nonatomic) id<MotionSourceDelegate> delegate;
@property (assign, nonatomic, getter = isDebugging) BOOL debugging;
@property (assign, nonatomic, getter = isConfiguring) BOOL configuring;

- (void)start;
- (void)stop;
- (void)showDebugWindow;
- (void)showConfigWindow;
- (void)hideConfigWindow;

@end

@protocol MotionSourceDelegate <NSObject>
- (void)motionSource:(MotionSource *)source didRotateByX:(CGFloat)xAmount andY:(CGFloat)yAmount;
@end