//
//  ConfigureWindowController.h
//  MPMotionDriver
//
//  Created by Adam Williams on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPImageView.h"

@protocol ConfigureDelegate;

@interface ConfigureWindowController : NSWindowController

@property (assign, nonatomic) IBOutlet MPImageView *imageView;
@property (assign, nonatomic) id<MPImageSource> imageSource;
@property (assign, nonatomic) id<ConfigureDelegate> configDelegate;

- (void)refreshSettings;

@end

@protocol ConfigureDelegate <NSObject>
- (void)configControllerWillSave:(ConfigureWindowController *)controller;
@end
