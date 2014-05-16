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
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

#define APP_NAME @"iPresta"
#define MOVIES_API_KEY @"1a42dcd12f15495cb8b85bfa74b6ea97"
#define MOVIE_IMAGE_URL @"https://image.tmdb.org/t/p/w185/%@"

#define STATE_TYPES @[NSLocalizedString(@"No prestado", nil), NSLocalizedString(@"Prestado", nil), NSLocalizedString(@"A devolver", nil)]
#define OBJECT_TYPES @[NSLocalizedString(@"Libro", nil), NSLocalizedString(@"Audio", nil), NSLocalizedString(@"Video", nil), NSLocalizedString(@"Otro", nil)]
#define AUDIO_OBJECT_TYPES @[@"CD", @"SACD", NSLocalizedString(@"Vinilo", nil)]
#define VIDEO_OBJECTS_TYPE @[@"DVD", @"Bluray", @"VHS"]
#define IMAGE_TYPES @[@"book_icon.png", @"audio_icon.png", @"video_icon.png", @"other_icon.png"]