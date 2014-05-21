//
//  Constants.h
//  iPresta
//
//  Created by Nacho on 16/12/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#define iPresta_Constants_h

#define IS_OS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IPHONE_4_INCHES (([[UIScreen mainScreen] bounds].size.height-568)? NO : YES)
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

#define APP_NAME @"iPresta"
#define IPString(string) NSLocalizedString(string, nil)
#define MOVIEDB_API_KEY @"1a42dcd12f15495cb8b85bfa74b6ea97"
#define MOVIEDB_IMAGE_URL @"https://image.tmdb.org/t/p/w185/%@"
#define FB_URL_IMAGE @"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1"

#define GBOOK_ISBN_URL @"https://www.googleapis.com/books/v1/volumes?q=isbn:%@"
#define DISCOGS_BCODE_URL @"http://api.discogs.com/search?q=%@"

#define GBOOKS_SEARCH_URL @"https://www.googleapis.com/books/v1/volumes?q=%@&maxResults=%d&startIndex=%d"
#define DISCOGS_SEARCH_URL @"http://api.discogs.com/database/search?title=%@&type=release&page=%d&per_page=%d"
#define MOVIEDB_SEARCH_URL @"http://api.themoviedb.org/3/search/movie?query=%@&page=%d&api_key=%@"

#define MOVIEDB_CAST_URL @"http://api.themoviedb.org/3/movie/%@/casts?api_key=%@"

#define STATE_TYPES @[IPString(@"No prestado"), IPString(@"Prestado"), IPString(@"A devolver")]
#define OBJECT_TYPES @[IPString(@"Libro"), IPString(@"Audio"), IPString(@"Video"), IPString(@"Otro")]
#define AUDIO_OBJECT_TYPES @[@"CD", @"SACD", IPString(@"Vinilo")]
#define VIDEO_OBJECTS_TYPE @[@"DVD", @"Bluray", @"VHS"]
#define IMAGE_TYPES @[@"book_icon.png", @"audio_icon.png", @"video_icon.png", @"other_icon.png"]
#define GIVE_TIMES @[IPString(@"1 Semana"), IPString(@"2 Semanas"), IPString(@"3 Semanas"), IPString(@"1 Mes"), IPString(@"2 Meses"), IPString(@"3 Meses")]