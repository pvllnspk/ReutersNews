//
//  ViewController.h
//  ReutersNewsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWFeedItem;

@interface WebViewController : UIViewController

@property (nonatomic, retain) NSArray *feeds;
@property (nonatomic, retain) MWFeedItem *feed;

@end
