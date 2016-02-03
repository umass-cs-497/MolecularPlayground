//
//  MotionDriver.h
//  MPMotionDriver
//
//  Created by Adam Williams on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MotionSource.h"
#import "GCDAsyncSocket.h"


@interface MotionDriver : NSObject <MotionSourceDelegate>

@property (retain, nonatomic) MotionSource *source;

- (id)initWithMotionSource:(MotionSource *)source;
- (void)startOnPort:(uint16_t)port;
- (void)stop;

@end
