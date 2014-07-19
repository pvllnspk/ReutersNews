//
//  EdgeInsetsLabel.m
//  ReutersNewsReader
//
//  Created by Barney on 8/18/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "EdgeInsetsLabel.h"

@implementation EdgeInsetsLabel

- (void)drawTextInRect:(CGRect)rect{
    
    UIEdgeInsets insets = {5, 10, 5, 10};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
