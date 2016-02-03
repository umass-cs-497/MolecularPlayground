//
//  MPTabViewController.m
//  MPControlHub
//
//  Created by Adam Williams on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabViewController.h"
#import "ControlHubAppDelegate.h"

@implementation TabViewController

@synthesize appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (ControlHubAppDelegate *)[[NSApplication sharedApplication] delegate];
    }
    
    return self;
}

@end
