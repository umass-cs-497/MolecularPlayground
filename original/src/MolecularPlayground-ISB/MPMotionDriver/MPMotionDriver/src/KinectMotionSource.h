//
//  KinectMotionSource.h
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MotionSource+Private.h"
#import <Kinect/Kinect.h>
#import "KinectConfigureWindowController.h"

@interface KinectMotionSource : MotionSource <ConfigureDelegate>

@end
