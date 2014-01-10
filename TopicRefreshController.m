//
//  TopicRefreshController.m
//  Demo App
//
//  Created by Vojtěch Šťavík on 08/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "TopicRefreshController.h"
#import "TwitterFetcher.h"
#import "GeoLocator.h"

@interface TopicRefreshController() <TwitterFetcherDelegate, GeoLocatorDelegate>

@property (nonatomic, readwrite) BOOL isFetchingTweets;
@property (nonatomic, readwrite) BOOL isGeolocating;

@property (nonatomic) int pocetDokoncenychGeolokaci;
@property (nonatomic) int pocetCelkovychGeolokaci;

@property (nonatomic) float progressInDownloading;
@property (nonatomic) float progressInGeolocation;

@property (nonatomic) int pocetStazenychTweetu;


@end

@implementation TopicRefreshController

- (TopicRefreshController *) init {
    
    self = [super init];
    
    self.isFetchingTweets = NO;
    self.isGeolocating = NO;
    
    return self;
}


#pragma mark - Downloading tweets

- (void) downloadNewTweets:(int)count refresh:(BOOL)refresh {
    
    self.pocetCelkovychGeolokaci = 0;
    self.pocetDokoncenychGeolokaci = 0;
    self.progressInDownloading = 0;
    self.progressInGeolocation = 0;
    
    self.pocetStazenychTweetu = 0;
    
    self.isGeolocating = NO;
    self.isFetchingTweets = NO;
    
    
    TwitterFetcher* tf = [TwitterFetcher getTwitterFetcher];
    
    tf.delegate = self;
    
    [tf getTweetsForTopic:self.topic count:count refresh:refresh];
    
}


- (void) didStartFetching:(id)sender {
    
    self.isFetchingTweets = YES;
    
}

- (void) didFinishFetching:(id)sender {
    
    self.isFetchingTweets = NO;
    
    self.progressInDownloading = 1;
    
    [self.delegate didFinishTweetsFetching:self];
    
    
    // provedeme geolokaci
    
    [self makeGeolocation];
    
}

- (void) numberOfDownloadedTweetsChanged:(int)numberOfDownloadedTweets initialCount:(int)initialCount {
    
    self.progressInDownloading = (float)numberOfDownloadedTweets / (float)initialCount;
    
    if (self.progressInDownloading > 1) self.progressInDownloading = 1;  // muze se stat pri updatu, kdy je pocet tweetu jen odhadovany
    
    
    
    [self.delegate progressChanged:self progress:self.progress];
        
}


#pragma mark - Geolocatin

- (void) makeGeolocation {
    
    self.isGeolocating = YES;
    
    [self.delegate didStartGeolocation:self];
    
    GeoLocator* geolocator = [[GeoLocator alloc] init];
    
    geolocator.delegate = self;
    
    [geolocator findGPSofTweetsOfTopic:self.topic];
    
}


- (void) didFinishGeolocationTask:(GeoLocator *)sender {
    
    self.pocetDokoncenychGeolokaci ++;
    
    
    if (self.pocetDokoncenychGeolokaci == self.pocetCelkovychGeolokaci) {
        
        self.isGeolocating = NO;
        
        [self.delegate didFinishGeolocation:self];
        
    } else {
        
        [self.delegate progressChanged:self progress:self.progress];
    }
    
}

- (void) geolocationWillStart: (GeoLocator *) sender count:(int)numberOfTweetsToGeolocate {
    
    self.pocetCelkovychGeolokaci = numberOfTweetsToGeolocate;
    
}



- (BOOL) isGeolocating {
    
    if (self.pocetCelkovychGeolokaci) {
        
        if (self.pocetDokoncenychGeolokaci == self.pocetCelkovychGeolokaci) {
            
            return NO;
            
        } else {
            
            return YES;
            
        }
        
    }
    
    return NO;
    
}


#pragma mark - Progress counting

- (float) progress {
    
    return (self.progressInDownloading/2 + self.progressInGeolocation/2);
    
}

- (float) progressInGeolocation {
    
    if (self.pocetCelkovychGeolokaci)

        return (float)self.pocetDokoncenychGeolokaci / (float)self.pocetCelkovychGeolokaci;
    
    else
    
        return 0;
        
}



@end
