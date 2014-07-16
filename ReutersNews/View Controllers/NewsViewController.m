//
//  NewsViewController.m
//  ReutersNews
//
//  Created by Barney on 7/13/14.
//  Copyright (c) 2014 pvllnspk. All rights reserved.
//

#import "NewsViewController.h"
#import "MWFeedParser.h"
#import "NSString+HTML.h"
#import "WebViewController.h"
#import "MBProgressHUD.h"
#import "NSDate-Utilities.h"
#import "UIImage+Additions.h"


#if 0
#define FPLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define FPLog(x, ...)
#endif


@interface NewsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, MWFeedParserDelegate>

@end


@implementation NewsViewController
{
    MWFeedParser *feedParser;
    NSDateFormatter *dateFormatter;
    UIRefreshControl *refreshControl;
    MBProgressHUD *HUD;
    
    NSMutableArray *parsedData;
    NSArray *displayData;
}


-(void) setRSSURL:(NSString *)feedURL{
    
    parsedData = [NSMutableArray array];
	displayData = [NSArray array];
    
    NSURL *feedUrl = [NSURL URLWithString:feedURL];
    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedUrl];
    feedParser.delegate = self;
    feedParser.feedParseType = ParseTypeFull;
    feedParser.connectionType = ConnectionTypeAsynchronously;
    [feedParser parse];
    
    self.tableView.userInteractionEnabled = NO;
    
    HUD.labelText = @"Loading...";
    [HUD show:YES];
}


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor colorWithWhite:.75f alpha:1.0]];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:HUD];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *_titleTextAttributes = @{UITextAttributeTextColor: [UIColor blackColor],
                                           UITextAttributeTextShadowColor : [UIColor clearColor],
                                           UITextAttributeFont : [[UIFont fontWithName:@"HelveticaNeue-Light" size:15] fontWithSize:20.0f]};
    
    [[UINavigationBar appearance] setTitleTextAttributes:_titleTextAttributes];
    // remove shadow
    [[UINavigationBar appearance]setShadowImage:[UIImage imageWithColor:[UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.00f]]];
}


- (void)viewWillAppear:(BOOL)animated{
    
//    [self.navigationController setNavigationBarHidden:YES];
}


- (void)viewWillDisappear:(BOOL)animated{
    
//    [self.navigationController setNavigationBarHidden:NO];
}


- (void)refresh{
    
	[parsedData removeAllObjects];
    
	[feedParser stopParsing];
	[feedParser parse];
	
    self.tableView.userInteractionEnabled = NO;
    HUD.labelText = @"Refreshing...";
    [HUD show:YES];
}


- (void)updateTableWithParsedData{
    
	displayData = [parsedData sortedArrayUsingDescriptors: [NSArray arrayWithObject:[[NSSortDescriptor alloc]
                                                                                     initWithKey:@"date" ascending:NO]]];
	self.tableView.userInteractionEnabled = YES;
    [HUD hide:YES];
    [refreshControl endRefreshing];
    
	[self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [displayData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MWFeedItem *feed = [displayData objectAtIndex:indexPath.row];
    if(feed){
        
        NSString *feedTitle = feed.title ? [feed.title stringByConvertingHTMLToPlainText] : @"[No Title]";
//		NSString *feedSummary = feed.summary ? [feed.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";

        UILabel *newsTitle = (UILabel *)[cell viewWithTag:101];
        newsTitle.text = feedTitle;
        
        UILabel *date = (UILabel *)[cell viewWithTag:102];
        date.text = [self getUserFriendlyDate:feed.date];
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"FeedSegue"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WebViewController *webViewController = segue.destinationViewController;
        [webViewController setFeed:[displayData objectAtIndex:indexPath.row]];
        [webViewController setFeeds:displayData];
    }
}


- (NSString*)getUserFriendlyDate:(NSDate *)date{
    
    if([date isToday]){
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];
        return [formatter stringFromDate:[NSDate date]];
        
    }else if([date isYesterday]){
        
        return @"Yesterday";
        
    }else{
        return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    }
}


#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser{
    
	FPLog(@"Started Parsing: %@", parser.url);
}


- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info{
    
	FPLog(@"Parsed Feed Info: “%@”", info.title);
}


- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item{
    
	FPLog(@"Parsed Feed Item: “%@”", item.title);
    
	if (item) [parsedData addObject:item];
}


- (void)feedParserDidFinish:(MWFeedParser *)parser{
    
	FPLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    
    [self updateTableWithParsedData];
}


- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error{
    
	FPLog(@"Finished Parsing With Error: %@", error);
    
    if (parsedData.count == 0) {
        self.title = @"Failed";
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing Incomplete"
                                                        message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self updateTableWithParsedData];
}


@end
