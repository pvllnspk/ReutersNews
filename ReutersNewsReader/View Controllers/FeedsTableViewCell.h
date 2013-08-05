//
//  FeedsTableViewCell.h
//  ReutersNewsReader
//
//  Created by Barney on 7/15/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedsTableViewCell;

@protocol FeedsTableViewCellDelegate <NSObject>

@optional
- (void)tableViewLongPressWithCell:(FeedsTableViewCell *)cell;
@end

@interface FeedsTableViewCell : UITableViewCell

@property (weak, nonatomic) id<FeedsTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *firstLevelText;
@property (weak, nonatomic) IBOutlet UILabel *secondLevelText;
@property (weak, nonatomic) IBOutlet UILabel *thirdLevelText;

@end
