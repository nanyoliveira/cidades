//
//  AppDelegate.m
//  cidades
//
//  Created by SBTUR Principal on 8/31/15.
//  Copyright (c) 2015 Ariane. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Foursquare-API-v2/Foursquare2.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


#define CLIENTE_ID @"0GBRZWD1RITVEQRUAYP5NWIBWZ13VSVBNFQXKWEM0NHKQ3TL"
#define CLIENTE_SECRET @"RLSBKA31BH4DERQFBXD5GNJA24BJN34UMPYF2P0QOWYRJOBG"
#define CALLBACK_URL @"https://cidades://foursquare"


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GMSServices provideAPIKey:@"AIzaSyAcjt3mKUq8NTvr8kflj-gx79stbd-Rb0s"];
    
    
    [Foursquare2 setupFoursquareWithClientId:CLIENTE_ID
                                      secret:CLIENTE_SECRET
                                 callbackURL:CALLBACK_URL];
    // Override point for customization after application launch.
    return  [[FBSDKApplicationDelegate sharedInstance] application:application
                                     didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ] || [Foursquare2 handleURL:url]   ;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
