//
//  AppDelegate.m
//  ReutersNewsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "AppDelegate.h"
#import "JSSlidingViewController.h"
#import "SectionsViewController.h"
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
        
        //        CategoriesViewController *categoriesViewController = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController_iPad" bundle:nil];
        //        self.navigationController = [[RNNavigationController alloc] initWithRootViewController:categoriesViewController];
        //        self.window.rootViewController = self.navigationController;
        
    } else{
        
        
        storyboard = [UIStoryboard storyboardWithName:@"Storyboard_phone" bundle:nil];
        SectionsViewController *sectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"Sections"];
        NavigationController *navViewController = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
        slidingViewController = [[JSSlidingViewController alloc] initWithFrontViewController:navViewController backViewController:sectionViewController];
        self.window.rootViewController = slidingViewController;
        
    }
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}


-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
