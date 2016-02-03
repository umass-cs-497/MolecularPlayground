//
//  Monitor.h
//  MPControlHub
//
//  Created by Adam Williams on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MonitorDelegate;

@interface Monitor : NSObject

@property (assign, nonatomic) id<MonitorDelegate> delegate;

+ (Monitor *)sharedMonitor;
- (void)startJmol;
- (void)killJmol;
- (void)startCamera;
- (void)killCamera;

@end
