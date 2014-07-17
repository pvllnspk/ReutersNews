//
//  ViewController.m
//  ReutersNewsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "WebViewController.h"
#import "MWFeedItem.h"
#import "TFHpple.h"
#import "HTMLParser.h"
#import "NSString+Additions.h"
#import "RNActivityViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM (NSInteger, FeedTransition)
{
    FeedTransitionNext,
    FeedTransitionPrevious
};

@interface WebViewController() <UIGestureRecognizerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController
{
    NSString* filePath;
}

-(void)viewDidLoad{
    
    [_webView setDelegate:self];
    [[_webView scrollView] setContentInset:UIEdgeInsetsMake(0, 0, 5, 0)];
    
    filePath = [[NSBundle mainBundle] pathForResource:@"view_phone" ofType:@"html"];
    
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
    
    [self refreshFeed:_feed];
}


- (void) refreshFeed:(MWFeedItem *)feed{
    
    if(feed == Nil)
        return;
    
    [self setFeed:feed];
    
    NSMutableString *html = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close();"];
    [html replaceOccurrencesOfString:@"[title]" withString:[_feed.title stringByStrippingHTML] options:0 range:NSMakeRange(0, html.length)];
    [_webView loadHTMLString:html baseURL:nil];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("dispatch_queue_#1", 0);
    dispatch_async(backgroundQueue, ^{
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_feed.link] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:15];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *result;
        NSString *feedText = [[NSString alloc]init];
        
        if (data && !error){
            
            result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            //Didn't manage to handle it properly neither with TFHpple nor HTMLParser
            feedText = [result stringBetweenString:@"<span id=\"midArticle_start\"></span>" andString:@"<div class="];
            if(feedText == NULL){
                feedText = result;
                NSLog(@"result: \n %@",result);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [html replaceOccurrencesOfString:@"Loading..." withString:feedText options:0 range:NSMakeRange(0, html.length)];
            [_webView loadHTMLString:html baseURL:nil];
        });
    });
}


-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer{
    
    if ([self indexOfFeed:_feed] == _feeds.count-1)
        return;
        
    [self transitionToType:FeedTransitionNext];
}


-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer{
    
    if ([self indexOfFeed:_feed] == 0){
        [self onBackButtonPressed:nil];
        return;
    }
    
    [self transitionToType:FeedTransitionPrevious];
}


- (IBAction)onBackButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onShareButtonPressed:(id)sender {
    
    NSURL *url = [NSURL URLWithString:_feed.link];
    UIActivityViewController *activityViewController = [RNActivityViewController controllerForURL:url];
    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated{
    
    [[AppDelegate appDelegate] toggleLockSlider];
}


- (void)viewWillDisappear:(BOOL)animated{
    
    [[AppDelegate appDelegate] toggleLockSlider];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}


- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


-(void)transitionToType:(FeedTransition) transitionType{
    
    CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    [stretchAnimation setToValue:[NSNumber numberWithFloat:1.02]];
    [stretchAnimation setRemovedOnCompletion:YES];
    [stretchAnimation setFillMode:kCAFillModeRemoved];
    [stretchAnimation setAutoreverses:YES];
    [stretchAnimation setDuration:0.2];
    [stretchAnimation setDelegate:self];
    [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.35];
    [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];
   
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:(transitionType == FeedTransitionNext ? kCATransitionFromRight : kCATransitionFromLeft)];
    [animation setDuration:0.65f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.webView layer] addAnimation:animation forKey:nil];

    switch (transitionType) {
        case FeedTransitionNext:

            [self refreshFeed:[self nextFeed]];

            break;
        case FeedTransitionPrevious:

            [self refreshFeed:[self previousFeed]];

            break;
        default:
            break;
    }
}


- (MWFeedItem *)nextFeed{
    
    int currentIndex = [self indexOfFeed:_feed];
    if (currentIndex == _feeds.count-1 || currentIndex == NSNotFound) return nil;
    return _feeds[++currentIndex];
}


- (MWFeedItem *)previousFeed{
    
    int currentIndex = [self indexOfFeed:_feed];
    if (currentIndex == 0 || currentIndex == NSNotFound) return nil;
    return _feeds[--currentIndex];
}


- (int)indexOfFeed:(MWFeedItem *)feed{
    
    int index = 0;
    for (MWFeedItem *f in _feeds){
        if ([feed.identifier isEqualToString:f.identifier]){
            return index;
        }
        index++;
    }
    return NSNotFound;
}

@end
