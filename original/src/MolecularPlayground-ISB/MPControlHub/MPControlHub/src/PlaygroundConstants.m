//
//  PlaygroundConstants.m
//  MPControlHub
//
//  Created by Adam Williams on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaygroundConstants.h"

NSInteger const MPCameraSourceKinect = 0;
NSInteger const MPCameraSourceFirewire = 1;
NSInteger const MPContentSourceLocal = 1;
NSInteger const MPContentSourceRemote = 0;
NSString *const MPKinectCameraType = @"Kinect";
NSString *const MPFirewireCameraType = @"Firewire";
NSString *const MPMotionDriverPath = @"../MPMotionDriver.app";

NSString *const MPServerPortKey = @"serverPort";
NSString *const MPJmolPathKey = @"jmolPath";
NSString *const MPJmolArgsKey = @"jmolArgs";
NSString *const MPCameraSourceKey = @"cameraSource";
NSString *const MPLaunchAtStartupKey = @"launchAtStartup";
NSString *const MPMonitorJmolKey = @"jmolMonitorProcess";
NSString *const MPJmolRestartDelayKey = @"jmolRestartDelay";
NSString *const MPMonitorContentKey = @"jmolMonitorContent";
NSString *const MPJmolContentIntervalKey = @"jmolContentInterval";
NSString *const MPMonitorCameraKey = @"cameraMonitorProcess";
NSString *const MPCameraRestartDelayKey = @"cameraRestartDelay";
NSString *const MPContentSourceKey = @"contentSource";
NSString *const MPAlternateBannerKey = @"alternatingBanner";
NSString *const MPAlternateBannerTextKey = @"alternatingBannerText";
NSString *const MPAlternateBannerDelayKey = @"alternatingBannerDelay";
NSString *const MPContentDisableOnErrorKey = @"contentDisableOnError";