//
//  RNController.m
//  ReutersNewsReader
//
//  Created by Barney on 7/15/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "RNHelper.h"

@implementation RNHelper

+ (id)sharedController
{
    static dispatch_once_t onceToken;
    static RNHelper *rnController;
    dispatch_once(&onceToken, ^{
        rnController = [[self alloc] init];
    });
    return rnController;
}

- (id)init
{
    self = [super init];
    if(self){
        //
    }
    return self;
}

+ (BOOL)isPad
{
    static BOOL isPad;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^
                  {
                      isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
                  });
    return isPad;
}

@end
