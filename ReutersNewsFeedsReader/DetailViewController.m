//
//  DetailViewController.m
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "DetailViewController.h"
#import "MWFeedParser.h"
#import "NSString+HTML.h"
#import "WebViewController.h"
#import "RNController.h"
#import "DetailTableViewCell.h"
#import "MBProgressHUD.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DetailTableViewCellDelegate>
{
    
    MWFeedParser *feedParser;
    NSMutableArray *parsedItems;
    
    NSArray *itemsToDisplay;
    NSDateFormatter *formatter;
    
    UIRefreshControl *refreshControl;
    
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation DetailViewController

@synthesize feedsURL;

#pragma mark - Managing the detail item


-(void)viewDidLoad
{
    
    UIEdgeInsets tableViewEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    [self.tableView setContentInset:tableViewEdgeInsets];
    [self.tableView setScrollIndicatorInsets:tableViewEdgeInsets];
    
    // Refresh button
//	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
//                                                                                           target:self
//                                                                                           action:@selector(refresh)];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor colorWithWhite:.75f alpha:1.0]];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
    
    if([RNController isPad]){
        [self.tableView registerNib:[UINib nibWithNibName:@"DetailTableViewCell_iPad" bundle:nil] forCellReuseIdentifier:@"Cell"];
    }else{
        [self.tableView registerNib:[UINib nibWithNibName:@"DetailTableViewCell_iPhone" bundle:nil] forCellReuseIdentifier:@"Cell"];
    }
    
//    HUD = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:HUD];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:HUD];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    parsedItems = [[NSMutableArray alloc] init];
	itemsToDisplay = [NSArray array];
    
//    self.title = @"Loading...";
    NSURL *feedUrl = [NSURL URLWithString:feedsURL];
    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedUrl];
    feedParser.delegate = self;
    feedParser.feedParseType = ParseTypeFull;
    feedParser.connectionType = ConnectionTypeAsynchronously;
    [feedParser parse];
    self.tableView.userInteractionEnabled = NO;
    
    HUD.labelText = @"Loading...";
    [HUD show:YES];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
}

#pragma mark -
#pragma mark Parsing

// Reset and reparse
- (void)refresh
{
//	self.title = @"Refreshing...";
	[parsedItems removeAllObjects];
	[feedParser stopParsing];
	[feedParser parse];
	self.tableView.userInteractionEnabled = NO;
    
     HUD.labelText = @"Refreshing...";
    [HUD show:YES];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)updateTableWithParsedItems
{
	itemsToDisplay = [parsedItems sortedArrayUsingDescriptors:
                      [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                           ascending:NO]]];
	self.tableView.userInteractionEnabled = YES;
    
    [HUD hide:YES];
    
	[self.tableView reloadData];
    
    [refreshControl endRefreshing];
    
    
}


#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser
{
	NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info
{
	NSLog(@"Parsed Feed Info: “%@”", info.title);
//	self.title = info.title;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item
{
	NSLog(@"Parsed Feed Item: “%@”", item.title);
	if (item) [parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser
{
	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    [self updateTableWithParsedItems];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error
{
	NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedItems.count == 0) {
        self.title = @"Failed"; // Show failed message in title
    } else {
        // Failed but some items parsed, so show and inform of error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing Incomplete"
                                                        message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self updateTableWithParsedItems];
}


#pragma mark
#pragma mark  Table View



// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return itemsToDisplay.count;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([RNController isPad]){
        
        return 115;
    }else{
        
        return 64;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setDelegate:self];
    
    if (cell == nil) {
        cell = [[DetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        //iPhone
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
	// Configure the cell.
	MWFeedItem *item = [itemsToDisplay objectAtIndex:indexPath.row];
	if (item) {
		
		// Process
		NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
		NSString *itemSummary = item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
		
		// Set
		cell.firstLevelText.font = [UIFont boldSystemFontOfSize:15];
		cell.firstLevelText.text = itemTitle;
		NSMutableString *subtitle = [NSMutableString string];
        
        if([RNController isPad]){
            
           [subtitle appendString:itemSummary];
            cell.secondLevelText.font = [UIFont boldSystemFontOfSize:14];
            cell.secondLevelText.text = subtitle;
            cell.thirdLevelText.text = [formatter stringFromDate:item.date];
        }else
        {
            cell.secondLevelText.font = [UIFont boldSystemFontOfSize:14];
            cell.secondLevelText.text = [formatter stringFromDate:item.date];
        }
        
 
		
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
	    if (!self.webViewController) {
	        self.webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController_iPhone" bundle:nil];
	    }
	    self.webViewController.item = (MWFeedItem *)[itemsToDisplay objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:self.webViewController animated:YES];
        
        // Deselect
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
 
    else {
        
        if (!self.webViewController) {
	        self.webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController_iPad" bundle:nil];
	    }
	    self.webViewController.item = (MWFeedItem *)[itemsToDisplay objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:self.webViewController animated:YES];
        
        // Deselect
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
}

-(void)tableViewLongPressWithCell:(DetailTableViewCell *)cell
{
    NSLog(@"tableViewLongPressWithCell");
}



@end
