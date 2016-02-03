//
//  KinectDevice.h
//  Kinect
//
//  Created by Adam Williams on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface KinectDevice : NSObject

+ (uint8_t *)colorImage; 
+ (uint16_t *)depthImage;

@end
