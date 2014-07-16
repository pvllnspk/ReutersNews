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


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"ReutersMobileRSS" ofType:@"plist"];
    newsSectionsKeys = [[[NSDictionary alloc] initWithContentsOfFile:plistPath] valueForKey:@"keys"];
    newsSectionsValues = [[[NSDictionary alloc] initWithContentsOfFile:plistPath] valueForKey:@"values"];
    newsSectionsIcons = [[[NSDictionary alloc] initWithContentsOfFile:plistPath] valueForKey:@"icons"];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *feedTitle = [newsSectionsKeys objectAtIndex:indexPath.row];
    NSString *feedURL = [newsSectionsValues objectAtIndex:indexPath.row];
    
    [[_slidingViewController backViewController] setTitle:feedTitle];
    [((NewsViewController*) [((UINavigationController*)[_slidingViewController frontViewController]) viewControllers][0]) setRSSURL:feedURL];
    
    [self toggleSlider];
}


- (void)toggleSlider {
    
    if ([_slidingViewController isOpen]) {
        [_slidingViewController closeSlider:YES completion:nil];
    } else {
        [_slidingViewController openSlider:YES completion:nil];
    }
}


@end
