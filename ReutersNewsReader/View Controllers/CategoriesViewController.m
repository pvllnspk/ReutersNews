//
//  CategoriesViewController.m
//  ReutersNewsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "CategoriesViewController.h"
#import "FeedsViewController.h"

@implementation CategoriesViewController
{
    NSDictionary *_feedsCategories;
}

#pragma mark -
#pragma mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Reuters News", @"Reuters News");
        if ([RNHelper isPad])
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
    
    //load the local plist file with all feeds categories
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"ReutersNewsRSSFeeds" ofType:@"plist"];
    _feedsCategories = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
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
    if([RNHelper isPad])
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
    //change a color and text of the tablevew sections
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
        if (![RNHelper isPad])
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:63.0f/255.0f alpha:1.0f];
    cell.textLabel.text = [[[_feedsCategories valueForKey:[[_feedsCategories allKeys] objectAtIndex:indexPath.section]] allKeys]
                           objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *feedsURL = [[[_feedsCategories valueForKey:[[_feedsCategories allKeys] objectAtIndex:indexPath.section]] allValues]
                          objectAtIndex:indexPath.row];
    NSString *feedsTitle = [[[_feedsCategories valueForKey:[[_feedsCategories allKeys] objectAtIndex:indexPath.section]] allKeys]
                            objectAtIndex:indexPath.row];
    
    if([RNHelper isPad])
    {
        if (!self.feedsViewController)
        {
	        self.feedsViewController = [[FeedsViewController alloc] initWithNibName:@"FeedsViewController_iPad" bundle:nil];
	    }
    }
    else
    {
        if (!self.feedsViewController)
        {
	        self.feedsViewController = [[FeedsViewController alloc] initWithNibName:@"FeedsViewController_iPhone" bundle:nil];
	    }
    }
    
    [self.feedsViewController setFeedsUrl:feedsURL];
    [self.feedsViewController setTitle:feedsTitle];
    [self.navigationController pushViewController:self.feedsViewController animated:YES];
}

@end
