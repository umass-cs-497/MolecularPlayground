//
//  MPImageView.m
//  MPMotionDriver
//
//  Created by Adam Williams on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MPImageView.h"

@interface MPImageView (Private)
- (void)initScene;
- (void)closeScene;
- (void)drawScene;
- (void)frameForTime:(const CVTimeStamp *)outputTime;
@end

@implementation MPImageView
{
    BOOL _showDepth;
    NSMutableDictionary *_drawings;
    NSPoint _point;
    
    GLuint _texture;
    CVDisplayLinkRef _displayLink;
}

@synthesize imageSource = _imageSource;
@synthesize upsideDown = _upsideDown;
@synthesize drawings = _drawings;
@synthesize allowsDrawing = _allowsDrawing;
@synthesize activeDrawingKey = _activeDrawingKey;

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [(MPImageView *)displayLinkContext frameForTime:outputTime];
    [pool release];
    return kCVReturnSuccess;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        _showDepth = NO;
        _upsideDown = NO;
        _allowsDrawing = NO;
        _drawings = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return self;
}

- (void)dealloc
{
    CVDisplayLinkRelease(_displayLink);
    [self closeScene];
    [_drawings release];
    [_activeDrawingKey release];
    [super dealloc];
}

- (void)prepareOpenGL
{    
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    [self initScene];
    
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(_displayLink, &displayLinkCallback, self);
    
    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
    
    CVDisplayLinkStart(_displayLink);
}

- (void)update
{
    NSOpenGLContext *context = [self openGLContext];
    CGLLockContext([context CGLContextObj]);
    [super update];
    CGLUnlockContext([context CGLContextObj]);
}

- (void)reshape
{
    NSOpenGLContext *context = [self openGLContext];
    CGLLockContext([context CGLContextObj]);
    NSView *view = [context view];
    if(view) {
        NSSize size = [self bounds].size;
        [context makeCurrentContext];
        glViewport(0, 0, size.width, size.height);
    }
    CGLUnlockContext([context CGLContextObj]);
}

- (void)frameForTime:(const CVTimeStamp *)outputTime
{
    [self drawRect:NSZeroRect];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSOpenGLContext *context = [self openGLContext];
    CGLLockContext([context CGLContextObj]);
    NSView *view = [context view];
    if(view) {
        [context makeCurrentContext];
        
        [self drawScene];
        
        GLenum err = glGetError();
        if(err != GL_NO_ERROR) NSLog(@"GLError %4x", err);
        
        [context flushBuffer];
    }
    CGLUnlockContext([context CGLContextObj]);
}

uint8_t map[2048*3];

- (void)initScene 
{    
	uint8_t *empty = (uint8_t*)malloc(MPFrameWidth * MPFrameHeight * 3);
    bzero(empty, MPFrameWidth * MPFrameHeight * 3);
    
	glGenTextures(1, &_texture);
	glBindTexture(GL_TEXTURE_2D, _texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, MPFrameWidth, MPFrameHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, empty);
        
    free(empty);
    
    for(int i = 0; i < 2048; i++) {
        float v = i/2048.0f;
		v = powf(v, 3)* 6;
        uint16_t gamma = v*6*256;
        
        int lb = gamma & 0xff;
		switch (gamma>>8) {
			case 0: // white -> red
                map[i*3+0] = 255;
				map[i*3+1] = 255-lb;
				map[i*3+2] = 255-lb;
				break;
			case 1: // red -> orange
				map[i*3+0] = 255;
				map[i*3+1] = lb;
				map[i*3+2] = 0;
				break;
			case 2: // orange -> green 
				map[i*3+0] = 255-lb;
				map[i*3+1] = 255;
				map[i*3+2] = 0;
				break;
			case 3: // green -> cyan
				map[i*3+0] = 0;
				map[i*3+1] = 255;
				map[i*3+2] = lb;
				break;
			case 4: // cyan -> blue
				map[i*3+0] = 0;
				map[i*3+1] = 255-lb;
				map[i*3+2] = 255;
				break;
			case 5: // blue -> black
				map[i*3+0] = 0;
				map[i*3+1] = 0;
				map[i*3+2] = 255-lb;
				break;
			default: // black
				map[i*3+0] = 0;
				map[i*3+1] = 0;
				map[i*3+2] = 0;
				break;
		}
	}	
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);    
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);	
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0.0f, 640.0, 480.0, 0.0f, -1.0f, 1.0f); // y-flip
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glDisable(GL_DEPTH_TEST);
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);	
}

- (void)drawScene 
{		
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();	
    glEnable(GL_TEXTURE_2D);
    
	if(_showDepth) {
        uint16_t *depth = [self.imageSource depthImage];
		if(depth) {
			
			uint8_t *mapped = (uint8_t *)malloc(MPFrameWidth * MPFrameHeight * 3);
			bzero(mapped, MPFrameWidth * MPFrameHeight * 3);
            
			for(int i = 0; i < MPFrameWidth * MPFrameHeight; i++) {
				mapped[i*3] = map[depth[i]*3];
				mapped[i*3+1] = map[depth[i]*3+1];
				mapped[i*3+2] = map[depth[i]*3+2];
			}
			glBindTexture(GL_TEXTURE_2D, _texture);
            
			glTexImage2D(GL_TEXTURE_2D, 0, 3, 640, 480, 0, GL_RGB, GL_UNSIGNED_BYTE, mapped);
			free(mapped);
		}
        free(depth);
	}
	else {
        uint8_t *video = [self.imageSource rgbImage];
		if(video) {
			glTexImage2D(GL_TEXTURE_2D, 0, 3, 640, 480, 0, GL_RGB, GL_UNSIGNED_BYTE, video);
		}
        free(video);
	}
	
	glBegin(GL_QUADS);
	glColor4f(255.0f, 255.0f, 255.0f, 1.0f);
    if(self.upsideDown) {
        glTexCoord2f(1, 1); glVertex2f(0, 0);
        glTexCoord2f(0, 1); glVertex2f(MPFrameWidth,0);
        glTexCoord2f(0, 0); glVertex2f(MPFrameWidth,MPFrameHeight);
        glTexCoord2f(1, 0); glVertex2f(0,MPFrameHeight);
    }
    else {
        glTexCoord2f(0, 0); glVertex2f(0, 0);
        glTexCoord2f(1, 0); glVertex2f(MPFrameWidth,0);
        glTexCoord2f(1, 1); glVertex2f(MPFrameWidth,MPFrameHeight);
        glTexCoord2f(0, 1); glVertex2f(0,MPFrameHeight);        
    }
	glEnd();
    
    NSValue *activeValue = [_drawings objectForKey:self.activeDrawingKey];
    if(activeValue != nil) {
        NSRect activeRect = activeValue.rectValue;
        glDisable(GL_TEXTURE_2D);
        glEnable (GL_BLEND);
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glBegin(GL_QUADS);
        glColor4f(255.0f, 0.0f, 0.0f, 0.5f);	
        glVertex2f(activeRect.origin.x, activeRect.origin.y);
        glVertex2f(activeRect.origin.x + activeRect.size.width, activeRect.origin.y);
        glVertex2f(activeRect.origin.x + activeRect.size.width, activeRect.origin.y + activeRect.size.height);
        glVertex2f(activeRect.origin.x, activeRect.origin.y + activeRect.size.height);
        glEnd();
    }
    
    glFlush();
}

- (void)closeScene
{
	glDeleteTextures(1, &_texture); 
    self.imageSource = nil;
}

- (void)mouseDown:(NSEvent *)theEvent 
{
    [super mouseDown:theEvent];
    
    NSPoint location = [theEvent locationInWindow];
	_point = [self convertPoint:location fromView:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
    [super mouseDragged:theEvent];
    
    NSPoint location = [theEvent locationInWindow];
	NSPoint currentPoint = [self convertPoint:location fromView:nil];
    
    NSValue *activeValue = [_drawings objectForKey:self.activeDrawingKey];
    if(activeValue == nil) return;
    
    NSRect activeRect  = activeValue.rectValue;
    // no drawing outside of the image!
    if(currentPoint.x < 0) currentPoint.x = 0;
    if(currentPoint.y < 0) currentPoint.y = 0;
    if(currentPoint.x >= MPFrameWidth) currentPoint.x = MPFrameWidth - 1;
    if(currentPoint.y >= MPFrameHeight) currentPoint.y = MPFrameHeight - 1;
    
    activeRect.origin.x = _point.x;
    activeRect.origin.y = MPFrameHeight - _point.y;   // flip y from NSView coords to OpenGL coords
    activeRect.size.width = currentPoint.x - _point.x;
    activeRect.size.height = _point.y - currentPoint.y;
    NSValue *newValue = [NSValue valueWithRect:activeRect];
    [_drawings setObject:newValue forKey:self.activeDrawingKey];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if(theEvent.clickCount == 2) {
        if([_imageSource respondsToSelector:@selector(depthImage)]) {
            _showDepth = !_showDepth;        
        }
        else {
            _showDepth = NO;
        }
    }
    else {
        NSValue *activeValue = [_drawings objectForKey:self.activeDrawingKey];
        if(activeValue == nil) return;
        
        NSRect activeRect  = activeValue.rectValue;
        // fix negative height/width
        if(activeRect.size.width < 0) {
            activeRect.origin.x += activeRect.size.width;
            activeRect.size.width *= -1;
        }
        
        if(activeRect.size.height < 0) {
            activeRect.origin.y += activeRect.size.height;
            activeRect.size.height *= -1;        
        }
        NSValue *newValue = [NSValue valueWithRect:activeRect];
        [_drawings setObject:newValue forKey:self.activeDrawingKey];
    }
}

@end
