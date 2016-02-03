//
//  SourceSettings.h
//  MPMotionDriver
//
//  Created by Adam Williams on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SourceSettings : NSObject

@property (readwrite, nonatomic) BOOL upsideDown;
@property (readwrite, nonatomic) float minMeters;
@property (readwrite, nonatomic) float maxMeters;
@property (readwrite, nonatomic) float motionScale;
@property (readwrite, nonatomic) int shutterSpeed;

+ (SourceSettings *)sharedSettings;
- (NSRect)activeRect;
- (void)setActiveRect:(NSRect)rect;

@end
