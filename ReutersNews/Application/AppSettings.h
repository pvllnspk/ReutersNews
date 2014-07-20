//
//  AppSettings.h
//  ReutersNews
//
//  Created by Barney on 7/13/14.
//  Copyright (c) 2014 pvllnspk. All rights reserved.
//

#ifndef ReutersNews_AppSettings_h
#define ReutersNews_AppSettings_h

#define IS_IPAD()           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define APP_VERSION         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define CACHE_SIZE_MEMORY   10*1024*1024

#define CACHE_SIZE_DISK     100*1024*1024

#endif
