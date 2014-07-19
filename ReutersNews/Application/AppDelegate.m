//
//  AppDelegate.m
//  ReutersNewsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "NewsViewController.h"
#import "NavigationController.h"

@implementation AppDelegate
{
    JSSlidingViewController *slidingViewController;
}

+ (AppDelegate *)appDelegate {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:CACHE_SIZE_MEMORY diskCapacity:CACHE_SIZE_DISK diskPath:@"rncache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard;
    
    if (IS_IPAD()){
        
        storyboard = [UIStoryboard storyboardWithName:@"Storyboard_pad" bundle:nil];
        UISplitViewController *splitViewController = [storyboard instantiateViewControllerWithIdentifier:@"Split"];
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.viewControllers[0];
        self.window.rootViewController = splitViewController;
        
    } else{
        
        storyboard = [UIStoryboard storyboardWithName:@"Storyboard_phone" bundle:nil];
        MenuViewController *menuViewController = [storyboard instantiateViewControllerWithIdentifier:@"Menu"];
        NavigationController *navViewController = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
        slidingViewController = [[JSSlidingViewController alloc] initWithFrontViewController:navViewController backViewController:menuViewController];
        menuViewController.slidingViewController = slidingViewController;
        self.window.rootViewController = slidingViewController;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)toggleSlider {
    
    if ([slidingViewController isOpen]) {
        [slidingViewController closeSlider:YES completion:nil];
    } else {
        [slidingViewController openSlider:YES completion:nil];
    }
}


- (void)toggleLockSlider {
    
    if ([slidingViewController locked]) {
        [slidingViewController setLocked:FALSE];
    } else {
        [slidingViewController setLocked:TRUE];
    }
}


-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
