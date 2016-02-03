//
//  FirewireCamera.h
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dc1394/dc1394.h>
#import "OpenCV.h"

@interface FirewireCamera : NSObject

@property (readwrite, nonatomic) int shutterSpeed;

- (id)initWith1394Camera:(dc1394camera_t *)camera;
- (void)start;
- (void)stop;
- (IplImage *)imageForCVImage:(IplImage *)image;

@end
