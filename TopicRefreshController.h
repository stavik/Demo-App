//
//  TopicRefreshController.h
//  Demo App
//
//  Created by Vojtěch Šťavík on 08/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//





////////// Spatne zvoleny nazev tridy, zavadejici. Nejedna se o ViewController, ale o controller aktualizaci - sorry





#import <Foundation/Foundation.h>
#import "Topic+Doplnky.h"

@class TopicRefreshController;

@protocol TopicRefreshControllerDelegate <NSObject>

- (void) didFinishTweetsFetching: (TopicRefreshController* ) sender;
- (void) didStartTweetsFetching: (TopicRefreshController* ) sender;

- (void) didFinishGeolocation: (TopicRefreshController* ) sender;
- (void) didStartGeolocation: (TopicRefreshController* ) sender;

- (void) progressChanged: (TopicRefreshController* ) sender progress:(float) progres;

@end


@interface TopicRefreshController : NSObject

@property (nonatomic, strong) Topic* topic;

@property (nonatomic, readonly) BOOL isFetchingTweets;
@property (nonatomic, readonly) BOOL isGeolocating;

@property (readonly) float progress;

@property (nonatomic, weak) id<TopicRefreshControllerDelegate> delegate;


- (void) downloadNewTweets:(int) count refresh:(BOOL) refresh;
- (void) makeGeolocation;

@end
