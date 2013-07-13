//
//  ViewController.m
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "WebViewController.h"
#import "MWFeedItem.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize webView;
@synthesize item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSURL *url = [NSURL URLWithString:item.link];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

@end
