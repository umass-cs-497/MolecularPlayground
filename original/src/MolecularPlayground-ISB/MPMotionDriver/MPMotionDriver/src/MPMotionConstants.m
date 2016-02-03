//
//  MPMotionConstants.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MPMotionConstants.h"

const int MPFrameWidth = 640;
const int MPFrameHeight = 480;
const int MPFrameRGBSize = MPFrameWidth * MPFrameHeight * 3;
NSString *const MPBackgroundModelFile = @"../Data/Private/bg.dat";

//NSUserDefaults keys
NSString *const MPMinMetersKey = @"minMeters";
NSString *const MPMaxMetersKey = @"maxMeters";
NSString *const MPMinXKey = @"minX";
NSString *const MPMinYKey = @"minY";
NSString *const MPMaxXKey = @"maxX";
NSString *const MPMaxYKey = @"maxY";
NSString *const MPUpsideDownKey = @"upsideDown";
NSString *const MPShutterSpeedKey = @"shutterSpeed";
NSString *const MPMotionScaleKey = @"motionScale";