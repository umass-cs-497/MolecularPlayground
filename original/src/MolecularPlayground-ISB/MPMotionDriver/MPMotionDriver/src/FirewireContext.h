//
//  FirewireContext.h
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dc1394/dc1394.h>

@class FirewireCamera;

@interface FirewireContext : NSObject

- (NSInteger)numberOfCameras;
- (FirewireCamera *)cameraAtIndex:(NSInteger)index;
- (FirewireCamera *)camera;

@end
