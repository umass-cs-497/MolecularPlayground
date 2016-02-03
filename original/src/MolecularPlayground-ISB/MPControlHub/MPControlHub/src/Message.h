//
//  Message.h
//  MPControlHub
//
//  Created by Adam Williams on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Content;

@interface Message : NSObject {
    NSDictionary *_rawMsg;
}

@property (readonly) NSData *data;

+ (Message *)cameraConfigureMessage;
+ (Message *)cameraDebugMessage;
+ (Message *)quitMessage;
+ (Message *)jmolContentMessageWithContent:(Content *)content atPath:(NSString *)path;
- (id)initWithDictionary:(NSDictionary *)info;
- (id)initWithData:(NSData *)data;
- (BOOL)isLoginType;
- (BOOL)isJmolMsg;
- (BOOL)isCameraMsg;
- (BOOL)isContentRequestMsg;
@end
