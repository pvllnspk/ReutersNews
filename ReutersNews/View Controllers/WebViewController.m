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

typedef NS_ENUM (NSInteger, FontSizeChangeType)
{
    FontSizeChangeTypeIncrease,
    FontSizeChangeTypeDecrease,
    FontSizeChangeTypeNone
};

@interface WebViewController() <UIGestureRecognizerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

//- (IBAction)tabButtonPressed:(id)sender;

@end

@implementation WebViewController
{
    MWFeedItem *currentFeed;
}


-(void)viewDidLoad{
    
    [_webView setDelegate:self];
    [[_webView scrollView] setContentInset:UIEdgeInsetsMake(0, 0, 5, 0)];
    
    [_webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close();"];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"view_phone" ofType:@"html"];
    NSMutableString* html = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
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
            //Didn't manage to do it properly neither with TFHpple nor HTMLParser
            feedText = [result stringBetweenString:@"<span id=\"midArticle_start\"></span>" andString:@"<div class=\"relatedTopicButtons\">"];            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [html replaceOccurrencesOfString:@"Loading..." withString:feedText options:0 range:NSMakeRange(0, html.length)];
            [_webView loadHTMLString:html baseURL:nil];
        });
    });
    
    
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
}


-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer{
    

}


-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer{
    
     [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES];
    [[AppDelegate appDelegate] toggleLockSlider];
}


- (void)viewWillDisappear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO];
    [[AppDelegate appDelegate] toggleLockSlider];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}


- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


//- (IBAction)tabButtonPressed:(id)sender
//{
//    int buttonTag = [sender tag];
//    switch (buttonTag) {
//        case 0:
//
//            [self back:nil];
//
//            break;
//        case 1:
//
//            [self transitionToType:FeedTransitionPrevious];
//
//            break;
//        case 2:
//
//            [self transitionToType:FeedTransitionNext];
//
//            break;
//        case 3:
//        {
//            NSURL *url = [NSURL URLWithString:currentFeed.link];
//            UIActivityViewController *activityViewController = [RNActivityViewController controllerForURL:url];
//            if ([RNHelper isPad])
//            {
////                _popoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
////                [_popoverController presentPopoverFromRect:self.shareButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//
//            }
//            else
//            {
//                [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
//            }
//        }
//            break;
//    }
//}

//-(IBAction)back:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

//-(void)transitionToType:(FeedTransition) transitionType
//{
//    CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
//    [stretchAnimation setToValue:[NSNumber numberWithFloat:1.02]];
//    [stretchAnimation setRemovedOnCompletion:YES];
//    [stretchAnimation setFillMode:kCAFillModeRemoved];
//    [stretchAnimation setAutoreverses:YES];
//    [stretchAnimation setDuration:0.2];
//    [stretchAnimation setDelegate:self];
//    [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.35];
//    [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    [self.view.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];
//    CATransition *animation = [CATransition animation];
//    [animation setType:kCATransitionPush];
//    [animation setSubtype:(transitionType == FeedTransitionNext ? kCATransitionFromTop : kCATransitionFromBottom)];
//    [animation setDuration:0.65f];
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    [[self.webView layer] addAnimation:animation forKey:nil];
//
//    switch (transitionType) {
//        case FeedTransitionNext:
//
//            [self setFeed:[self nextFeed]];
//
//            break;
//        case FeedTransitionPrevious:
//
//            [self setFeed:[self previousFeed]];
//
//            break;
//        default:
//            break;
//    }
//}

//#pragma mark -
//#pragma mark Utility Methods
//
//- (MWFeedItem *)nextFeed;
//{
//    int currentIndex = [self indexOfFeed:currentFeed];
//    if (currentIndex == _feeds.count-1 || currentIndex == NSNotFound) return nil;
//    return _feeds[++currentIndex];
//}
//
//- (MWFeedItem *)previousFeed;
//{
//    int currentIndex = [self indexOfFeed:currentFeed];
//    if (currentIndex == 0 || currentIndex == NSNotFound) return nil;
//    return _feeds[--currentIndex];
//}
//
//- (int)indexOfFeed:(MWFeedItem *)feed
//{
//    int index = 0;
//    for (MWFeedItem *f in _feeds)
//    {
//        if ([feed.identifier isEqualToString:f.identifier])
//        {
//            return index;
//        }
//        index++;
//    }
//    return NSNotFound;
//}

@end
