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
    
   
    NSArray* tweetsForGeolocation = [self tweetsForGeolocationFromTopic:topic];

    [self.delegate geolocationWillStart:self count:[tweetsForGeolocation count]];

    
    for (Tweet* t in tweetsForGeolocation) {

        __block Tweet* tweet = t;
        
        NSString* hledanyVyraz = tweet.location.nameOfLocation;
                
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

 
                        tweet.location.latitude = [NSNumber numberWithFloat:[latitudeString floatValue]];
                        tweet.location.longitude = [NSNumber numberWithFloat:[longitudeString floatValue]];



                    } else if([statusString isEqualToString:@"OVER_QUERY_LIMIT"]) {
                        
                        NSLog(@"Chyba, dosaženo limitu pro geolokaci");
                        
                        // TODO ošetřit zobrazení
                        
                                                
                    }
             
                    else {
                    
                        NSLog(@"Nelze rozpoznat adresu. Mažu tweet.");
                        
                        // smazeme tweet, location nastavíme na invalid
                        
                        tweet.location.longitude = [NSNumber numberWithFloat:INVALID_GPS];
                        tweet.location.latitude = [NSNumber numberWithFloat:INVALID_GPS];      // typ je float kvuli pozdeji jednotnosti v porovnavani
                        
                        [tweet performSelectorOnMainThread:@selector(deleteThisTweet) withObject:nil waitUntilDone:NO];
                    }
                    
                    
                    [self.delegate didFinishGeolocationTask:self]; }
                    
                   
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                    NSLog(@"Chyba načítání geolokace.");
                
                    NSLog([error description]);
                      
                    [self.delegate didFinishGeolocationTask:self];

                  }];

            
        
        }

}



- (NSArray* ) tweetsForGeolocationFromTopic: (Topic* ) topic {
    
    NSMutableArray* tweets = [[NSMutableArray alloc] init];
    
    for (Tweet* tweet in topic.tweets) {
        
        if ( ([tweet.location.latitude isEqualToNumber:[NSNumber numberWithFloat:INVALID_GPS]]) || ([tweet.location.longitude isEqualToNumber:[NSNumber numberWithFloat:INVALID_GPS]]) ) {
            
            // tweet nema platnou lokaci, rovnou ho smazeme  ... stava se u tweetu s lokaci jako "Home" "Middle-earth" apod. nebo u prázdných názvů lokace @""
            
            [tweet performSelectorOnMainThread:@selector(deleteThisTweet) withObject:nil waitUntilDone:NO];
            
        }
        
        
        // geolokaci provádím jen u tweetů, které ještě nemají platné GPS své lokace, ale název lokace mají vyplněný
        
        else if ([tweet.location.longitude floatValue] == 0 || [tweet.location.latitude floatValue] == 0)
            
        {
            
            [tweets addObject:tweet];
        }
    
    
    }
    
    return [tweets copy];
}


@end
