//
//  MotionMessage.h
//  MPMotionDriver
//
//  Created by Adam Williams on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONKit.h"

@interface MotionMessage : NSObject

@property (readonly, nonatomic) NSData *data;

+ (MotionMessage *)newLoginMessage;                             // RETURN VALUE NOT AUTORELEASED
+ (MotionMessage *)newMessageForRotation:(CGPoint)rotation;     // RETURN VALUE NOT AUTORELEASED
- (id)initWithData:(NSData *)data;
- (id)initWithDictionary:(NSDictionary *)info;
- (BOOL)isDebugViewMessage;
- (BOOL)isConfigureMessage;
- (BOOL)isQuitMessage;

@end
