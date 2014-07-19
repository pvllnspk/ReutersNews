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
#import "NSDate-Utilities.h"
#import "AppDelegate.h"


#if 0
#define FPLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define FPLog(x, ...)
#endif


@interface NewsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, MWFeedParserDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (strong, nonatomic) WebViewController *webViewController;

@end


@implementation NewsViewController
{
    MWFeedParser *feedParser;
    NSDateFormatter *dateFormatter;
    UIRefreshControl *refreshControl;
    
    NSMutableArray *parsedData;
    NSArray *displayData;
}


-(void) setRSSURL:(NSString *)feedURL{
    
    self.tableView.userInteractionEnabled = NO;
    [refreshControl beginRefreshing];
    
    parsedData = [NSMutableArray array];
	displayData = [NSArray array];
    
    NSURL *feedUrl = [NSURL URLWithString:feedURL];
    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedUrl];
    feedParser.delegate = self;
    feedParser.feedParseType = ParseTypeFull;
    feedParser.connectionType = ConnectionTypeAsynchronously;
    [feedParser parse];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
    if(self.navigationController.topViewController != self){
        
        [self.navigationController popViewControllerAnimated:YES];
    }
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
}


- (void)viewWillAppear:(BOOL)animated{
    
    //    [self.navigationController setNavigationBarHidden:YES];
}


- (void)viewWillDisappear:(BOOL)animated{
    
    //    [self.navigationController setNavigationBarHidden:NO];
}


- (IBAction)menuButtonPressed:(id)sender {
    
    [[AppDelegate appDelegate] toggleSlider];
}


- (void)refresh{
    [refreshControl beginRefreshing];
    
	[parsedData removeAllObjects];
    
	[feedParser stopParsing];
	[feedParser parse];
	
    self.tableView.userInteractionEnabled = NO;
}


- (void)updateTableWithParsedData{
    
	displayData = [parsedData sortedArrayUsingDescriptors: [NSArray arrayWithObject:[[NSSortDescriptor alloc]
                                                                                     initWithKey:@"date" ascending:NO]]];
	self.tableView.userInteractionEnabled = YES;
    
	[self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    [refreshControl endRefreshing];
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
		NSString *feedSummary = feed.summary ? [feed.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
        
        UILabel *newsTitle = (UILabel *)[cell viewWithTag:101];
        UILabel *newsSummary = (UILabel *)[cell viewWithTag:102];
        newsTitle.text = feedTitle;
        newsSummary.text = feedSummary;
        
        UILabel *date = (UILabel *)[cell viewWithTag:103];
        date.text = [self getUserFriendlyDate:feed.date];
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"FeedSegue"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        _webViewController = segue.destinationViewController;
        [_webViewController setFeed:[displayData objectAtIndex:indexPath.row]];
        [_webViewController setFeeds:displayData];
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


- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController{
//    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
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
