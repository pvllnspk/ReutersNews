//
//  RNActivityViewController.m
//  ReutersNewsReader
//
//  Created by Barney on 7/21/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "RNActivityViewController.h"
#import "TUSafariActivity.h"
#import "ReadabilityActivity.h"

@implementation RNActivityViewController

+ (UIActivityViewController *)controllerForURL:(NSURL *)URL
{
    NSMutableArray *activities = [[NSMutableArray alloc]init];
    TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
    [activities addObject:safariActivity];
    if ([ReadabilityActivity canPerformActivity])
    {
        ReadabilityActivity *readabilityActivity = [[ReadabilityActivity alloc] init];
        [activities addObject:readabilityActivity];
    }
    UIActivityViewController *activityViewController = [[super alloc] initWithActivityItems:@[URL] applicationActivities:activities];
    [activityViewController setExcludedActivityTypes:@[UIActivityTypePostToWeibo]];
    return activityViewController;
}

@end
