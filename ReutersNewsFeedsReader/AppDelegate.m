//
//  AppDelegate.m
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "AppDelegate.h"
#import "CategoriesViewController.h"
#import "AppConfig.h"
#import "RNNavigationController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    int cacheSizeMemory = 10*1024*1024;
    int cacheSizeDisk = 100*1024*1024;
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"rnfrcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([RNHelper isPad])
    {
        CategoriesViewController *categoriesViewController = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController_iPad" bundle:nil];
        self.navigationController = [[RNNavigationController alloc] initWithRootViewController:categoriesViewController];
        self.window.rootViewController = self.navigationController;
        
    } else
    {
        CategoriesViewController *categoriesViewController = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController_iPhone" bundle:nil];
        self.navigationController = [[RNNavigationController alloc] initWithRootViewController:categoriesViewController];
        self.window.rootViewController = self.navigationController;
        
    }
    
    [self.window makeKeyAndVisible];
    
    //change the navigation bar color
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[UIColor colorWithRed:25.0f/255.0f green:25.0f/255.0f blue:25.0f/255.0f alpha:1.0f]];
    
    return YES;
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}



@end
