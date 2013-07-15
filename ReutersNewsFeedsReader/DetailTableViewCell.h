//
//  DetailViewTableViewCell.h
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/15/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *firstLevelText;
@property (weak, nonatomic) IBOutlet UILabel *secondLevelText;

@end
