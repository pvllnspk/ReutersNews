//
//  MasterViewController.m
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@implementation MasterViewController
{
    NSDictionary *_feedsCategories;
    NSMutableArray *_feedsTitles;
    NSMutableArray *_feedsURLs;
}


#pragma mark -
#pragma mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Reuters News", @"Reuters News");
        if ([RNController isPad])
        {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load a local plist file with feeds categories
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"ReutersNewsRSSFeeds" ofType:@"plist"];
    _feedsCategories = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    _feedsTitles = [[NSMutableArray alloc]init];
    _feedsURLs = [[NSMutableArray alloc]init];
    
    NSArray *feeds = [_feedsCategories allValues];
    for(id feed in feeds){
        [_feedsTitles addObjectsFromArray:[feed allKeys]];
        [_feedsURLs addObjectsFromArray:[feed allValues]];
    }
}


#pragma mark -
#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_feedsCategories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_feedsCategories valueForKey:[[_feedsCategories allKeys] objectAtIndex:section]] count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([RNController isPad])
    {
        return 64;
    }
    else
    {
        return 46;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //change color and text of the tablevew sections
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 320.0, 22.0)];
    customView.backgroundColor = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:63.0f/255.0f alpha:0.5f];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    headerLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    headerLabel.frame = CGRectMake(11,-11, 320.0, 44.0);
    headerLabel.text = [[_feedsCategories allKeys] objectAtIndex:section];
    [customView addSubview:headerLabel];
    return customView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if (![RNController isPad])
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:63.0f/255.0f alpha:1.0f];
    cell.textLabel.text = [_feedsTitles objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *feedsURL = [_feedsURLs objectAtIndex:indexPath.row];
    NSString *feedsTitle = [_feedsTitles objectAtIndex:indexPath.row];
    
    if([RNController isPad])
    {
        if (!self.detailViewController)
        {
	        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil];
	    }
    }
    else
    {
        if (!self.detailViewController)
        {
	        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
	    }
    }
    
    [self.detailViewController setFeedsUrl:feedsURL];
    [self.detailViewController setTitle:feedsTitle];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
