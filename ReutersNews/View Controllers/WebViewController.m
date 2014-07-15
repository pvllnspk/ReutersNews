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
            HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
            
            if (error) {
                NSLog(@"Error: %@", error);
                return;
            }
            
            HTMLNode *bodyNode = [parser body];
            NSArray *spanNodes = [bodyNode findChildTags:@"span"];
            for (HTMLNode *spanNode in spanNodes) {
                if ([[spanNode getAttributeNamed:@"class"] isEqualToString:@"focusParagraph"]) {
                    feedText = [spanNode rawContents];
                    NSLog(@" feedText    %@", [spanNode rawContents]);
                }
            }
            
            
//            TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
//            NSString *findImagesXpathQueryString = @"//div[@id='articleImage']";
//            NSArray *textNodes = [doc searchWithXPathQuery:findImagesXpathQueryString];
//            
//            if([textNodes count]>0)
//            {
//                TFHppleElement *element = [textNodes objectAtIndex:0];
//                TFHppleElement *childElement =[element firstChildWithTagName: @"img"];
//                feedText = [feedText stringByAppendingString:[NSString stringWithFormat:@"<img src='%@' border='0'/>",[childElement objectForKey:@"src"]]];
//                feedText = [feedText stringByAppendingString:[NSString stringWithFormat:@"<p class='alt'>%@</p>",[[childElement objectForKey:@"alt"] stringByStrippingHTML]]];
//            }
            
            
            
            //TODO: didn't manage to parse it with the TFHpple => extract midArticle data manually
            //TODO: TRY WITH REGULAR EXPRESSIONS
            
            for(int i=0;i<20;i++){
                NSString *str = [result stringBetweenString:[NSString stringWithFormat:@"midArticle_%d",i] andString:[NSString stringWithFormat:@"midArticle_%d",i+1]];
                if(str)
                {
                    feedText = [feedText stringByAppendingString:str];
                }
            }
            
            for(int i=0;i<20;i++){
                NSString *str = [result lastStringBetweenString:[NSString stringWithFormat:@"midArticle_%d",i] andString:[NSString stringWithFormat:@"midArticle_%d",i+1]];
                if(str && [feedText rangeOfString:str].location == NSNotFound)
                {
                    feedText = [feedText stringByAppendingString:str];
                }
            }
            
            //fix
            @try {
                NSRange location = [feedText rangeOfString:@"\"></span>"];
                feedText = [feedText stringByReplacingCharactersInRange:location withString:@""];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
            @finally {
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [html replaceOccurrencesOfString:@"Loading..." withString:feedText options:0 range:NSMakeRange(0, html.length)];
            [_webView loadHTMLString:html baseURL:nil];
            
        });
    });
    
}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [self.navigationController setNavigationBarHidden:YES];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [self.navigationController setNavigationBarHidden:NO];
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
//}


//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//}


//#pragma mark -
//#pragma mark Fontsize Change
//
//- (IBAction)fontSizePinch:(id)sender
//{
//    UIPinchGestureRecognizer *pinch = sender;
//    if (pinch.state == UIGestureRecognizerStateRecognized)
//    {
//        [self changeFontSize:(pinch.scale > 1)?FontSizeChangeTypeIncrease:FontSizeChangeTypeDecrease];
//    }
//}

//- (void)changeFontSize:(FontSizeChangeType)changeType
//{
//    if (changeType == FontSizeChangeTypeIncrease && currentFontSize == 160) return;
//    if (changeType == FontSizeChangeTypeDecrease && currentFontSize == 50) return;
//    if (changeType != FontSizeChangeTypeNone)
//    {
//        currentFontSize = (changeType == FontSizeChangeTypeIncrease) ? currentFontSize + 5 : currentFontSize - 5;
//        [[NSUserDefaults standardUserDefaults] setInteger:currentFontSize forKey:@"fontsize"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
//                          currentFontSize];
//    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
//}


//#pragma mark -
//#pragma mark User Interaction Callbacks
//
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
