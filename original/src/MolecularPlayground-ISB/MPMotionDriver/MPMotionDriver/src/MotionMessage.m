//
//  MotionMessage.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MotionMessage.h"

@implementation MotionMessage
{
    NSDictionary *_rawMsg;
}

+ (MotionMessage *)newLoginMessage
{
    NSDictionary *loginInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Camera", @"source",
                               @"login", @"type", nil];
    MotionMessage *message = [[self alloc] initWithDictionary:loginInfo];
    [loginInfo release];
    return message;
}

+ (MotionMessage *)newMessageForRotation:(CGPoint)rotation
{
    NSDictionary *rotateInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Camera", @"source",
                                @"move", @"type",
                                @"rotate", @"style",
                                [NSNumber numberWithFloat:rotation.x], @"x",
                                [NSNumber numberWithFloat:rotation.y], @"y", nil];
    MotionMessage *message = [[self alloc] initWithDictionary:rotateInfo];
    [rotateInfo release];
    return message;
}

- (id)initWithDictionary:(NSDictionary *)info
{
    self = [super init];
    if(self) {
        _rawMsg = [info copy];
    }
    return self;
}

- (id)initWithData:(NSData *)data
{
    return [self initWithDictionary: [data objectFromJSONDataWithParseOptions:JKParseOptionPermitTextAfterValidJSON]]; 
}

- (id)init
{
    return [self initWithDictionary:[[NSDictionary alloc] init]];
}

- (void)dealloc
{
    [_rawMsg release];
    [super dealloc];
}

- (NSData *)data
{
    NSString *terminatedString = [[NSString alloc] initWithFormat:@"%@\r\n", [_rawMsg JSONString]];
    NSData *messageData = [terminatedString dataUsingEncoding:NSUTF8StringEncoding];
    [terminatedString release];
    return messageData;
}

- (BOOL)isDebugViewMessage
{
    return [[_rawMsg objectForKey:@"type"] isEqualToString:@"debug"];
}

- (BOOL)isConfigureMessage
{
    return [[_rawMsg objectForKey:@"type"] isEqualToString:@"configure"];
}

- (BOOL)isQuitMessage
{
    return [[_rawMsg objectForKey:@"type"] isEqualToString:@"quit"];
}

@end
