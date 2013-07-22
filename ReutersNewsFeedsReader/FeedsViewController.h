//
//  FeedsViewController.h
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebViewController;

@interface FeedsViewController : UITableViewController

@property (strong, nonatomic) WebViewController *webViewController;
@property (nonatomic, retain, setter = setFeedsUrl:) NSString *feedsURL;

@end
