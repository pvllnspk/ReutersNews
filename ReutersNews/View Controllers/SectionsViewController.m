//
//  SectionsViewController.m
//  ReutersNews
//
//  Created by Barney on 7/13/14.
//  Copyright (c) 2014 pvllnspk. All rights reserved.
//

#import "SectionsViewController.h"

@implementation SectionsViewController
{
    NSArray* newsSectionsKeys, *newsSectionsValues;
}


- (id)initWithStyle:(UITableViewStyle)style{
    
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Select a section", @"Select a section");
    }
    return self;
}


- (void)viewDidLoad{
    
    [super viewDidLoad];

    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"ReutersMobileRSS" ofType:@"plist"];
    newsSectionsKeys = [[[NSDictionary alloc] initWithContentsOfFile:plistPath] valueForKey:@"keys"];
    newsSectionsValues = [[[NSDictionary alloc] initWithContentsOfFile:plistPath] valueForKey:@"values"];
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
     cell.textLabel.text = [newsSectionsKeys objectAtIndex:indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     [newsSectionsValues objectAtIndex:indexPath.row];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
