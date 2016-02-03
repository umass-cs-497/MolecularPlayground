//
//  FirewireContext.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirewireContext.h"
#import "FirewireCamera.h"

@implementation FirewireContext
{
    dc1394_t *_context;
}

- (id)init
{
    self = [super init];
    if(self) {
        _context = dc1394_new();
    }
    return self;
}

- (void)dealloc
{
    dc1394_free(_context);
    
    [super dealloc];
}

- (NSInteger)numberOfCameras
{
    dc1394camera_list_t *cameraList;
    dc1394error_t error;
    
    error = dc1394_camera_enumerate(_context, &cameraList);
    if(error != DC1394_SUCCESS) {
        return 0;
    }
    
    int numCameras = cameraList->num;
    dc1394_camera_free_list(cameraList);
    return numCameras;
}

- (FirewireCamera *)cameraAtIndex:(NSInteger)index
{
    dc1394camera_list_t *cameraList;
    dc1394error_t error;
    dc1394camera_t *camera;
    
    error = dc1394_camera_enumerate(_context, &cameraList);
    if(error != DC1394_SUCCESS) {
        return nil;
    }
    
    if(cameraList->num > 0 && index >= 0 && index < cameraList->num) {
        camera = dc1394_camera_new(_context, cameraList->ids[index].guid);
    }
    dc1394_camera_free_list(cameraList);
    
    if(camera == NULL) return nil;
    return [[[FirewireCamera alloc] initWith1394Camera:camera] autorelease];
}

- (FirewireCamera *)camera
{
    return [self cameraAtIndex:0];
}

@end
