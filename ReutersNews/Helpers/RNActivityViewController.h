//
//  RNActivityViewController.h
//  ReutersNewsReader
//
//  Created by Barney on 7/21/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RNActivityViewController : UIActivityViewController

+ (UIActivityViewController*)controllerForURL:(NSURL*)URL;

@end
