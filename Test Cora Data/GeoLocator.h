//
//  GeoLocator.h
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 05/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet+Doplnky.h"
#import "Topic+Doplnky.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@class GeoLocator;

@protocol GeoLocatorDelegate <NSObject>

- (void) didFinishGeolocation: (GeoLocator *) sender;
- (void) geolocationWillStart: (GeoLocator *) sender;

@end


@interface GeoLocator : NSObject

@property (strong, nonatomic) id<GeoLocatorDelegate> delegate;

- (void) findGPSofTweetsOfTopic: (Topic *) topic ;

@end

