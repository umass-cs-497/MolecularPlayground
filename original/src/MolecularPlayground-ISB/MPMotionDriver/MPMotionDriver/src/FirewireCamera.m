//
//  FirewireCamera.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirewireCamera.h"

@implementation FirewireCamera
{
    dc1394camera_t *_camera;
}

- (id)initWith1394Camera:(dc1394camera_t *)camera
{
    self = [super init];
    if(self) {
        _camera = camera;
        dc1394_video_set_iso_speed(_camera, DC1394_ISO_SPEED_400);
        dc1394_video_set_mode(_camera, DC1394_VIDEO_MODE_640x480_MONO8);
        dc1394_video_set_framerate(_camera, DC1394_FRAMERATE_30);
        dc1394_capture_setup(_camera, 4, DC1394_CAPTURE_FLAGS_DEFAULT);
        dc1394_feature_set_mode(_camera, DC1394_FEATURE_SHUTTER, DC1394_FEATURE_MODE_MANUAL);
    }
    return self;
}

- (void)dealloc
{
    dc1394_capture_stop(_camera);
    dc1394_camera_free(_camera);
    
    [super dealloc];
}

- (void)start
{
    dc1394_video_set_transmission(_camera, DC1394_ON);
}

- (void)stop
{
    dc1394_video_set_transmission(_camera, DC1394_OFF);
}

- (IplImage *)imageForCVImage:(IplImage *)image
{
    dc1394video_frame_t *frame;
    dc1394error_t error;
    
    error = dc1394_capture_dequeue(_camera, DC1394_CAPTURE_POLICY_WAIT, &frame);
    if(error != DC1394_SUCCESS) {
        return NULL;
    }
    
    memcpy(image->imageData, frame->image, MPFrameWidth * MPFrameHeight);
    dc1394_capture_enqueue(_camera, frame);
    return image;
}

- (void)setShutterSpeed:(int)speed
{
    dc1394_feature_set_value(_camera, DC1394_FEATURE_SHUTTER, speed);
}

- (int)shutterSpeed
{
    uint32_t value;
    dc1394_feature_get_value(_camera, DC1394_FEATURE_SHUTTER, &value);
    return (int)value;
}

@end
