//
//  Tweet+Create.h
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 03/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "Tweet.h"

#import <MapKit/MapKit.h>

@interface Tweet (Create) <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* subtitle;

+ (Tweet *) newTweetWithID: (long long int) tweetID InManagedObjectContext: (NSManagedObjectContext *) context;

- (void) deleteThisTweet;

@end
