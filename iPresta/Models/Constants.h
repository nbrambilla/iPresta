//
//  Constants.h
//  iPresta
//
//  Created by Nacho on 16/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#define iPresta_Constants_h

#define IS_OS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)? NO : YES)
#define APP_NAME @"iPresta"
#define MOVIES_API_KEY @"1a42dcd12f15495cb8b85bfa74b6ea97"
#define MOVIE_IMAGE_URL @"https://image.tmdb.org/t/p/w185/%@"