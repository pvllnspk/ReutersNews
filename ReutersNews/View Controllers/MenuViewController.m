//
//  SectionsViewController.m
//  ReutersNews
//
//  Created by Barney on 7/13/14.
//  Copyright (c) 2014 pvllnspk. All rights reserved.
//

#import "MenuViewController.h"
#import "AppDelegate.h"
#import "NewsViewController.h"

@interface MenuViewController ()

@property (strong, nonatomic) NewsViewController *newsViewController;

@end

@implementation MenuViewController
{
    NSArray* newsSectionsKeys, *newsSectionsValues, *newsSectionsIcons;
}


- (id)initWithStyle:(UITableViewStyle)style{
    
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Select a section";
    }
    return self;
}

- (void)awakeFromNib{
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    if(IS_IPAD()){
        
        _newsViewController = (NewsViewController *)[self.splitViewController delegate];
    }else{
        
        _newsViewController = [((UINavigationController*)[_slidingViewController frontViewController]) viewControllers][0];
    }
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"ReutersMobileRSS" ofType:@"plist"];
    newsSectionsKeys = [[[NSDictionary alloc] initWithContentsOfFile:plistPath] valueForKey:@"keys"];
    newsSectionsValues = [[[NSDictionary alloc] initWithContentsOfFile:plistPath] valueForKey:@"values"];
    newsSectionsIcons = [[[NSDictionary alloc] initWithContentsOfFile:plistPath] valueForKey:@"icons"];
    
    [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [newsSectionsKeys count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIImageView *newsSectionImage = (UIImageView *)[cell viewWithTag:101];
    
    UILabel *newsSection = (UILabel *)[cell viewWithTag:102];
    newsSection.text = [newsSectionsKeys objectAtIndex:indexPath.row];
    [newsSectionImage setImage:[UIImage imageNamed:[newsSectionsIcons objectAtIndex:indexPath.row]]];
    
    cell.selectedBackgroundView = [UIView new];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.914 green:0.914 blue:0.914 alpha:1];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *feedTitle = [newsSectionsKeys objectAtIndex:indexPath.row];
    NSString *feedURL = [newsSectionsValues objectAtIndex:indexPath.row];

    [_newsViewController setTitle:feedTitle];
    [_newsViewController setRSSURL:feedURL];
    
    [[AppDelegate appDelegate] toggleSlider];
}

@end
