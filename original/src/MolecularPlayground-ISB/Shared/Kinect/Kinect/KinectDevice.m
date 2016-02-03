//
//  KinectDevice.m
//  Kinect
//
//  Created by Adam Williams on 1/23/12.
//  Copyright (c) 2012 UMass - Amherst. All rights reserved.
//

#import "KinectDevice.h"
#import "libfreenect.h"
#import "libfreenect_sync.h"

@implementation KinectDevice

+ (uint8_t *)colorImage
{
    static uint8_t *data = 0;
    unsigned int timestamp;
    if(freenect_sync_get_video((void **)&data, &timestamp, 0, FREENECT_VIDEO_RGB)) {
        return NULL;
    }
    return data;
}

+ (uint16_t *)depthImage
{
    static uint16_t *data = 0;
    unsigned int timestamp;
    if(freenect_sync_get_depth((void **)&data, &timestamp, 0, FREENECT_DEPTH_11BIT)) {
        return NULL;
    }
    return data;
}

@end
