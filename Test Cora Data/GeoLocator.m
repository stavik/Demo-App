//
//  GeoLocator.m
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 05/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "GeoLocator.h"
#import "AFNetworking.h"

@interface GeoLocator ()

@end


@implementation GeoLocator


// pro geolokaci pouzivam Gmaps, funguji mi lip nez Apple

#define GMAPS_ADDRESS @"http://maps.googleapis.com/maps/api/geocode/json"


- (void) findGPSofTweetsOfTopic:(Topic *)topic {
   
    for (Tweet* t in topic.tweets) {
       
        
        __block Tweet* tweet = t;
        
        
        // geolokaci provádím jen u tweetů, které ještě nemají platné GPS souřadnice
        if ([tweet.longitude floatValue] == 0 || [tweet.latitude floatValue] == 0)
        
        {
            
            if ([tweet.location isEqualToString:@""]) {
                
                // pokud není vyplněno pole lokace, tweet hned mažu
                
                [tweet performSelectorOnMainThread:@selector(deleteThisTweet) withObject:nil waitUntilDone:NO];
                
            }
            
            else
                
            {
                
                [self.delegate geolocationWillStart:self];
                
                NSString* hledanyVyraz = tweet.location;
                
                NSURL *authURL = [NSURL URLWithString:GMAPS_ADDRESS];
            
                AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL: authURL];
            
                manager.responseSerializer = [AFJSONResponseSerializer serializer];
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            
                NSDictionary* parameters = [[NSDictionary alloc] initWithObjectsAndKeys:hledanyVyraz, @"address", @"true", @"sensor", nil];
            
                [manager GET:GMAPS_ADDRESS parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                    NSString *statusString = [responseObject valueForKey:@"status"];
                    
                    if ([statusString isEqualToString:@"OK"]) {
                        
                        NSArray *locationArray = [[[responseObject valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"];
                
                        locationArray = [locationArray objectAtIndex:0];
                
                        NSString *latitudeString = [locationArray valueForKey:@"lat"];
                        NSString *longitudeString = [locationArray valueForKey:@"lng"];

 
                        tweet.latitude = [NSNumber numberWithFloat:[latitudeString floatValue]];
                        tweet.longitude = [NSNumber numberWithFloat:[longitudeString floatValue]];


#ifdef DEBUG
                        
                        NSLog(@"Geolokace načtena v pořádku. %@ %@ \n",latitudeString,longitudeString);
                    
#endif

                    }
             
                    else {
                    
                        NSLog(@"Nelze rozpoznat adresu. Mažu tweet.");
                        
                        [tweet performSelectorOnMainThread:@selector(deleteThisTweet) withObject:nil waitUntilDone:NO];
                    }
                    
                    
                    [self.delegate didFinishGeolocation:self]; }
                    
                   
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                    NSLog(@"Chyba načítání geolokace.");
                
                    NSLog([error description]);
                      
                    [self.delegate didFinishGeolocation:self];

                  }];

            }
        
        }

    }

}


@end
