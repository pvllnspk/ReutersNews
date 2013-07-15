//
//  NSString+Additions.h
//  ReutersNewsFeedsReader
//
//  Created by Barney on 7/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (NSString *)sha1;
- (NSString *)md5;

- (NSString*)stringBetweenString:(NSString *)start andString:(NSString *)end;

@end
