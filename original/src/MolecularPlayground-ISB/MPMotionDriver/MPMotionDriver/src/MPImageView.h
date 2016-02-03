//
//  MPImageView.h
//  MPMotionDriver
//
//  Created by Adam Williams on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreVideo/CoreVideo.h>
#import <OpenGL/OpenGL.h>

@protocol MPImageSource;

@interface MPImageView : NSOpenGLView

@property (assign, nonatomic) IBOutlet id<MPImageSource> imageSource;
@property (assign, nonatomic, getter = isUpsideDown) BOOL upsideDown;
@property (assign, nonatomic) BOOL allowsDrawing;
@property (readonly, nonatomic) NSMutableDictionary *drawings;
@property (copy, nonatomic) NSString *activeDrawingKey;

@end

@protocol MPImageSource <NSObject>
@required
- (uint8_t *)rgbImage;
@optional
- (uint16_t *)depthImage;
@end