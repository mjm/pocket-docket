//
//  DOAppDelegate.m
//  PocketDocket
//
//  Created by Matt Moriarity on 4/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DOAppDelegate.h"


@implementation DOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[window addSubview:splitViewController.view];
	[window makeKeyAndVisible];
	
	return YES;
}

@end
