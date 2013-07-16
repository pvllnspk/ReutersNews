//
//  ViewController.m
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "WebViewController.h"
#import "MWFeedItem.h"
#import "TFHpple.h"
#import "NSString+Additions.h"

@interface WebViewController () <UIGestureRecognizerDelegate,UIWebViewDelegate>

@end

@implementation WebViewController


-(void)viewDidLoad
{
    [_webView setDelegate:self];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close();"];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"view_phone" ofType:@"html"];
    NSMutableString* html = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [html replaceOccurrencesOfString:@"[title]" withString:[_item.title stringByStrippingHTML] options:0 range:NSMakeRange(0, html.length)];
     [_webView loadHTMLString:html baseURL:nil];

     dispatch_queue_t backgroundQueue = dispatch_queue_create("dispatch_queue_#1", 0);
     dispatch_async(backgroundQueue, ^{
         
         NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_item.link] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:15];
         NSURLResponse *response = nil;
         NSError *error = nil;
         NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
         NSString *result;
         NSString *text = [[NSString alloc]init];

         
         if (data && !error) {
             result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
              NSString *textXpathQueryString = @"//div[@id='articleImage']";
              NSArray *textNodes = [doc searchWithXPathQuery:textXpathQueryString];
        
             
             if([textNodes count]>0)
             {
                 TFHppleElement *element = [textNodes objectAtIndex:0];
                 TFHppleElement *childElement =[element firstChildWithTagName: @"img"];
                 text = [text stringByAppendingString:[NSString stringWithFormat:@"<img src='%@' border='0'/>",[childElement objectForKey:@"src"]]];
                 text = [text stringByAppendingString:[NSString stringWithFormat:@"<p class='domain'>%@</p>",[[childElement objectForKey:@"alt"] stringByStrippingHTML]]];
             }
             
             
             //didn't manage to parse it with the TFHpple
             for(int i=0;i<20;i++){
                 NSString *str = [result stringBetweenString:[NSString stringWithFormat:@"midArticle_%d",i] andString:[NSString stringWithFormat:@"midArticle_%d",i+1]];
                 if(str){
        
                     text = [text stringByAppendingString:str];
                     text = [text stringByAppendingString:@"\n\n\t"];
                     
                 }
             }
             
             for(int i=0;i<20;i++){
                 NSString *str = [result lastStringBetweenString:[NSString stringWithFormat:@"midArticle_%d",i] andString:[NSString stringWithFormat:@"midArticle_%d",i+1]];
                 if(str && [text rangeOfString:str].location == NSNotFound){
                     
                     text = [text stringByAppendingString:str];
                     text = [text stringByAppendingString:@"\n\n\t"];
                     
                 }
             }

//             NSLog(@"resultresultresult %@ ",text);
             
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [html replaceOccurrencesOfString:@"Loading..." withString:[text stringByStrippingHTML] options:0 range:NSMakeRange(0, html.length)];
              [_webView loadHTMLString:html baseURL:nil];
             
         });
    });
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

@end
