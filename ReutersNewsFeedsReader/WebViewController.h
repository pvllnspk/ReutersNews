//
//  ViewController.h
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedItem.h"

@interface WebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) MWFeedItem *item;

@end
