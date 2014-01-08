//
//  Topic+Create.h
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 03/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "Topic.h"
#import "Tweet.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Topic (Create)

+ (Topic *) topicWithString: (NSString *) name inManagedObjectContext: (NSManagedObjectContext *) context;

- (Tweet* ) getOldestTweet;
- (Tweet* ) getNewestTweet;

- (NSArray* ) getSortedTweets;

- (BOOL) containsTweet: (Tweet * ) tweet;


// debug

- (void) printSortedTweets;

@end
