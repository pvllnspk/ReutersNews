//
//  FeedsViewController.m
//  ReutersNewsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "FeedsViewController.h"
#import "MWFeedParser.h"
#import "NSString+HTML.h"
#import "WebViewController.h"
#import "FeedsTableViewCell.h"
#import "MBProgressHUD.h"
#import "RNActivityViewController.h"

// Feed Parser Logging
#if 0 // Set to 1 to enable Feed Parser Logging
#define FPLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define FPLog(x, ...)
#endif

@interface FeedsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, FeedsTableViewCellDelegate, MWFeedParserDelegate>

@property (strong, nonatomic) UIPopoverController *categoriesPopoverController;

@end

@implementation FeedsViewController
{
    MWFeedParser *_feedParser;
    NSMutableArray *_parsedItems;
    
    NSArray *_itemsToDisplay;
    NSDateFormatter *_formatter;
    
    UIRefreshControl *_refreshControl;
    
    MBProgressHUD *_HUD;
    
    UIPopoverController *_popoverController;
}


#pragma mark -
#pragma mark Set Feeds Url

-(void) setFeedsUrl:(NSString *)feedsUrl
{    
    _parsedItems = [[NSMutableArray alloc] init];
	_itemsToDisplay = [NSArray array];
    
    NSURL *feedUrl = [NSURL URLWithString:feedsUrl];
    _feedParser = [[MWFeedParser alloc] initWithFeedURL:feedUrl];
    _feedParser.delegate = self;
    _feedParser.feedParseType = ParseTypeFull;
    _feedParser.connectionType = ConnectionTypeAsynchronously;
    [_feedParser parse];
    self.tableView.userInteractionEnabled = NO;
    
    _HUD.labelText = @"Loading...";
    [_HUD show:YES];
    
    if (self.categoriesPopoverController != nil) {
        [self.categoriesPopoverController dismissPopoverAnimated:YES];
    }
}


#pragma mark -
#pragma mark View Lifecycle

-(void)viewDidLoad
{
    UIEdgeInsets tableViewEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 0);
    [self.tableView setContentInset:tableViewEdgeInsets];
    [self.tableView setScrollIndicatorInsets:tableViewEdgeInsets];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl setTintColor:[UIColor colorWithWhite:.75f alpha:1.0]];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    _formatter = [[NSDateFormatter alloc] init];
	[_formatter setDateStyle:NSDateFormatterShortStyle];
	[_formatter setTimeStyle:NSDateFormatterShortStyle];
    
    if([RNHelper isPad])
    {
        [self.tableView registerNib:[UINib nibWithNibName:@"FeedsTableViewCell_iPad" bundle:nil] forCellReuseIdentifier:@"Cell"];
    }
    else
    {
        [self.tableView registerNib:[UINib nibWithNibName:@"FeedsTableViewCell_iPhone" bundle:nil] forCellReuseIdentifier:@"Cell"];
    }
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:_HUD];
}


#pragma mark -
#pragma mark Parsing

// Reset and reparse
- (void)refresh
{
	[_parsedItems removeAllObjects];
	[_feedParser stopParsing];
	[_feedParser parse];
	self.tableView.userInteractionEnabled = NO;
    
     _HUD.labelText = @"Refreshing...";
    [_HUD show:YES];
    
    if (self.categoriesPopoverController != nil) {
        [self.categoriesPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)updateTableWithParsedItems
{
	_itemsToDisplay = [_parsedItems sortedArrayUsingDescriptors:
                      [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                           ascending:NO]]];
	self.tableView.userInteractionEnabled = YES;
    
    [_HUD hide:YES];
    
	[self.tableView reloadData];
    //restore tableview scroll
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    [_refreshControl endRefreshing];
}


#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser
{
	FPLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info
{
	FPLog(@"Parsed Feed Info: “%@”", info.title);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item
{
	FPLog(@"Parsed Feed Item: “%@”", item.title);
	if (item) [_parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser
{
	FPLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    [self updateTableWithParsedItems];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error
{
	FPLog(@"Finished Parsing With Error: %@", error);
    if (_parsedItems.count == 0) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemsToDisplay.count;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([RNHelper isPad])
    {
        return 115;
    }
    else
    {
        return 64;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    FeedsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setDelegate:self];
    
    if (cell == nil)
    {
        cell = [[FeedsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        if (![RNHelper isPad])
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
	// Configure the cell.
	MWFeedItem *item = [_itemsToDisplay objectAtIndex:indexPath.row];
	if (item)
    {
		// Process
		NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
		NSString *itemSummary = item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
		
		// Set
		cell.firstLevelText.font = [UIFont boldSystemFontOfSize:15];
		cell.firstLevelText.text = itemTitle;
		NSMutableString *subtitle = [NSMutableString string];
        
        if([RNHelper isPad])
        {
           [subtitle appendString:itemSummary];
            cell.secondLevelText.font = [UIFont boldSystemFontOfSize:14];
            cell.secondLevelText.text = subtitle;
            cell.thirdLevelText.text = [_formatter stringFromDate:item.date];
        }
        else
        {
            cell.secondLevelText.font = [UIFont boldSystemFontOfSize:14];
            cell.secondLevelText.text = [_formatter stringFromDate:item.date];
        }		
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([RNHelper isPad ])
    {
        if (!self.webViewController)
        {
	        self.webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController_iPad" bundle:nil];
	    }
    }
    else
    {
        if (!self.webViewController) {
	        self.webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController_iPhone" bundle:nil];
	    }
    }
    
    [self.webViewController setFeeds: _itemsToDisplay];
    [self.webViewController setFeed:(MWFeedItem *)[_itemsToDisplay objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:self.webViewController animated:YES];
    
    // Deselect
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableViewLongPressWithCell:(FeedsTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath)
    {
        NSURL *url = [NSURL URLWithString:((MWFeedItem *)[_itemsToDisplay objectAtIndex:indexPath.row]).link];
        UIActivityViewController *activityViewController = [RNActivityViewController controllerForURL:url];
        if ([RNHelper isPad])
        {
            CGRect cellFrame = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:indexPath] toView:[self.tableView superview]];
            cellFrame.size.height = cell.frame.size.height/2;
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            [_popoverController presentPopoverFromRect:cellFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown animated:YES];
        }
        else
        {
            [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
        }
    }
}

@end
