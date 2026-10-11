//
//  AppDelegate.m
//  Wheaton App
//
//  Created by Chris Anderson on 3/13/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//
//  NOTICE: Substantially modified by an LLM (Claude Code), 2026-10-11:
//  removed Mixpanel, push notifications, reachability, and the device UUID.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x00447c)];
    return YES;
}

@end
