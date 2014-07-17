//
//  NavigationController.m
//  ReutersNews
//
//  Created by Barney on 7/13/14.
//  Copyright (c) 2014 pvllnspk. All rights reserved.
//

#import "NavigationController.h"
#import "UIImage+Additions.h"

@interface NavigationController ()

@end

@implementation NavigationController

-(void) viewDidLoad{
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *_titleTextAttributes = @{UITextAttributeTextColor: [UIColor blackColor],
                                           UITextAttributeTextShadowColor : [UIColor clearColor],
                                           UITextAttributeFont : [[UIFont fontWithName:@"HelveticaNeue-Light" size:15] fontWithSize:20.0f]};
    
    [[UINavigationBar appearance] setTitleTextAttributes:_titleTextAttributes];
    [[UINavigationBar appearance]setShadowImage:[UIImage imageWithColor:[UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.00f]]];
}


@end
