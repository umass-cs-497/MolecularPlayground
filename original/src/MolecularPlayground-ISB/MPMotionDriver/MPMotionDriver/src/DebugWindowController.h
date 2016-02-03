//
//  DebugWindowController.h
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPImageView.h"

@interface DebugWindowController : NSWindowController

@property (assign, nonatomic) IBOutlet MPImageView *debugView;
@property (assign, nonatomic) id<MPImageSource> imageSource;

@end
