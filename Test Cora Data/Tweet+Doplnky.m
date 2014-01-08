//
//  Tweet+Create.m
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 03/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "Tweet+Doplnky.h"
#import "AppDelegate.h"

@implementation Tweet (Create)


+ (Tweet *) newTweetWithID: (long long int) tweetID InManagedObjectContext: (NSManagedObjectContext *) context {
    
    Tweet* newTweet = nil;
    
    if (tweetID) {
        
        NSString* stringID = [NSString stringWithFormat:@"%lli",tweetID];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
                request.predicate = [NSPredicate predicateWithFormat:@"id = %@", stringID];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            
            NSLog(@"Chyba načítání z databáze");
            
        } else if (![matches count]) {
            newTweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet"
                                                     inManagedObjectContext:context];
            newTweet.id = [NSNumber numberWithLongLong:tweetID];
            newTweet.latitude = 0;
            newTweet.longitude = 0;
            
        } else {
            
            // pokud uz tweet v DB je, vracíme nil
  
            
            newTweet = nil;
            
            // newTweet = [matches lastObject];
        }
    }
    
    return newTweet;
    
}


- (void) deleteThisTweet {

    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* context = [delegate managedObjectContext];
    
    
    NSString* stringID = [NSString stringWithFormat:@"%lli",[self.id longLongValue]];
    
    if ([stringID isEqualToString:@"0"]) {
        
        NSLog(@"Nejaka chybka ktery zatim nerozumim");
        
    }
   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", stringID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        
        NSLog(@"Chyba načítání z databáze");
        
    } else if (![matches count]) {

                NSLog(@"Tweet nelze smazat protože není v DB :)");
        
    } else {
        [context deleteObject:[matches lastObject]];
        
#ifdef DEBUG
        
        NSLog(@"Tweet smazán");
        
#endif
        
    }
    
}

- (NSString *) title {
    
    return self.user;
    
}

- (NSString *) subtitle {
    
    return self.text;
    
}

- (CLLocationCoordinate2D) coordinate {
    
    return CLLocationCoordinate2DMake([self.latitude floatValue], [self.longitude floatValue]);
    
}

@end
