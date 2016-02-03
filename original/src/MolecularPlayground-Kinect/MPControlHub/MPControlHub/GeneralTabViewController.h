//
//  MPGeneralTabViewController.h
//  MPControlHub
//
//  Created by Adam on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerManager.h"

@interface GeneralTabViewController : NSViewController

@property (retain) ServerManager *manager;
@property (copy) NSString *uptimeStatus;
@property (copy) NSString *lastError;
@property (copy) NSString *jmolStatus;
@property (copy) NSString *remoteStatus;
@property (copy) NSString *kinectStatus;

- (id)initWithServerManager:(ServerManager *)manager;
- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)debugView:(id)sender;
- (IBAction)configView:(id)sender;
- (IBAction)quitApp:(id)sender;
@end
