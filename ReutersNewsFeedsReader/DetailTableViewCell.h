//
//  DetailViewTableViewCell.h
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/15/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailTableViewCell;

@protocol DetailTableViewCellDelegate <NSObject>

@optional
- (void)tableViewLongPressWithCell:(DetailTableViewCell *)cell;
@end

@interface DetailTableViewCell : UITableViewCell

@property (weak, nonatomic) id<DetailTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *firstLevelText;
@property (weak, nonatomic) IBOutlet UILabel *secondLevelText;
@property (weak, nonatomic) IBOutlet UILabel *thirdLevelText;

@end
