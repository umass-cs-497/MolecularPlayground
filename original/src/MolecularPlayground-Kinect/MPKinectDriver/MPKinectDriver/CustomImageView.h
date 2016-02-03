//
//  CustomImageView.h
//  MPKinectSource
//
//  Created by Adam on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomImageView : NSImageView {
    
    int originX;
    int originY;
    int width;
    int height;
    
    NSPoint downPoint;
}

@property (assign) int originX;
@property (assign) int originY;
@property (assign) int width;
@property (assign) int height;

@end
