//
//  DetailViewController.h
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebViewController;

@interface DetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) WebViewController *webViewController;
@property (nonatomic, retain) NSString *feedsURL;

@end
