//
//  CustomImageView.m
//  MPKinectSource
//
//  Created by Adam on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomImageView.h"


@implementation CustomImageView

@synthesize originX;
@synthesize originY;
@synthesize width;
@synthesize height;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder])
    {
        NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
        originX = [myDefaults integerForKey:@"originX"];
        originY = [myDefaults integerForKey:@"originY"];
        width = [myDefaults integerForKey:@"width"];
        height = [myDefaults integerForKey:@"height"];
    }
    return self;  
    
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    //[[NSColor redColor] setFill];
    [[NSColor colorWithDeviceRed:1.0f green:0.0f blue:0.0f alpha:0.5f] setFill];
    NSRect rect;
    
    rect.origin.x = originX;
    rect.origin.y = originY;
    rect.size.width = width;
    rect.size.height = height;
    
    [NSBezierPath fillRect:rect];
    
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint location = [theEvent locationInWindow];
	downPoint = [self convertPoint:location fromView:nil];
}

//- (void)mouseUp:(NSEvent *)theEvent {
//    
//    
//}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint location = [theEvent locationInWindow];
	NSPoint currentPoint = [self convertPoint:location fromView:nil];   
    
    originX = downPoint.x;
    originY = currentPoint.y;
    
    width = currentPoint.x - downPoint.x;
    height = downPoint.y - currentPoint.y;
    
    [self setNeedsDisplay];
    
}

@end
