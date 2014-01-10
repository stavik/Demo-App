//
//  TwitterFetcher.h
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 03/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Topic.h"


@protocol TwitterFetcherDelegate <NSObject>


- (void) didFinishFetching: (id) sender;

- (void) numberOfDownloadedTweetsChanged:(int) numberOfDownloadedTweets initialCount: (int) initialCount;

- (void) didStartFetching: (id) sender;

@end



@interface TwitterFetcher : NSObject


@property (weak, nonatomic) id<TwitterFetcherDelegate> delegate;
@property (strong, nonatomic) Topic* topic;


+ (TwitterFetcher *) getTwitterFetcher;

- (void) getTweetsForTopic:(Topic *)topic count:(NSInteger)count refresh:(BOOL)refresh;


@end

