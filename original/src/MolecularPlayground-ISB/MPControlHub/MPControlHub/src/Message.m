//
//  Message.m
//  MPControlHub
//
//  Created by Adam Williams on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "JSONKit.h"
#import "Message.h"
#import "Content.h"
#import "Playground.h"

@implementation Message

+ (Message *)cameraConfigureMessage
{
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"Hub", @"source",
                                                                    @"configure", @"type", nil];
    return [[[self alloc] initWithDictionary:info] autorelease];
}

+ (Message *)cameraDebugMessage
{
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"Hub", @"source",
                                                                    @"debug", @"type", nil];
    return [[[self alloc] initWithDictionary:info] autorelease];
}

+ (Message *)quitMessage
{
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"Hub", @"source",
                                                                    @"quit", @"type", nil];
    return [[[self alloc] initWithDictionary:info] autorelease];
}

+ (Message *)jmolContentMessageWithContent:(Content *)content atPath:(NSString *)path
{
    
    BOOL useAltBanner = [[NSUserDefaults standardUserDefaults] boolForKey:MPAlternateBannerKey];
    NSInteger delay = [[NSUserDefaults standardUserDefaults] integerForKey:MPAlternateBannerDelayKey];
    NSString *altText = [[NSUserDefaults standardUserDefaults] stringForKey:MPAlternateBannerTextKey];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"Hub", @"source",
                                                                    @"content", @"type",
                                                                    path, @"path",
                                                                    (useAltBanner) ? @"on" : @"off", @"altBanner",
                                                                    [NSNumber numberWithInteger:delay], @"altBannerDelay",
                                                                    altText, @"altBannerText",
                                                                    content.contentKey, @"key", nil];
    return [[[self alloc] initWithDictionary:info] autorelease];    
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
    return [self initWithDictionary:[data objectFromJSONDataWithParseOptions:JKParseOptionPermitTextAfterValidJSON]];
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

- (NSString *)description
{
    return [_rawMsg description];
}

#pragma mark - Accessor methods

- (NSData *)data
{
    NSString *terminatedString = [[NSString alloc] initWithFormat:@"%@\r\n", [_rawMsg JSONString]];
    NSData *messageData = [terminatedString dataUsingEncoding:NSUTF8StringEncoding];
    [terminatedString release];
    return messageData;
}

- (BOOL)isLoginType
{
    return [[_rawMsg objectForKey:@"type"] isEqualToString:@"login"];
}

- (BOOL)isJmolMsg
{
    return [[_rawMsg objectForKey:@"source"] isEqualToString:@"Jmol"];
}

- (BOOL)isCameraMsg
{
    return [[_rawMsg objectForKey:@"source"] isEqualToString:@"Camera"];
}

- (BOOL)isContentRequestMsg
{
    return [[_rawMsg objectForKey:@"type"] isEqualToString:@"contentRequest"];
}

@end
