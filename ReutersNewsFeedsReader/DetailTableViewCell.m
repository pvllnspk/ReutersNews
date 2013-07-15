//
//  DetailViewTableViewCell.m
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/15/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "DetailTableViewCell.h"

@implementation DetailTableViewCell

@synthesize firstLevelText;
@synthesize secondLevelText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
