//
//  Tweet+Create.m
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 03/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "Tweet+Doplnky.h"
#import "Location+Doplnky.h"
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
            
        } else {
            
            // pokud uz tweet v DB je, vracíme nil
            
            // TODO - co kdyz by byl jeden tweet pro 2 temata? Je potreba osetrit aktualizace atd.
            
            
            newTweet = nil;
            
        }
    }
    
    return newTweet;
    
}


- (void) deleteThisTweet {

    NSManagedObjectContext* context = self.managedObjectContext;
    
    NSString* stringID = [NSString stringWithFormat:@"%lli",[self.id longLongValue]];
    
   
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
        
        
    }
    
}

- (NSString *) title {
    
    return self.user;
    
}

- (NSString *) subtitle {
    
    return self.text;
    
}

- (CLLocationCoordinate2D) coordinate {
    
    return CLLocationCoordinate2DMake([self.location.latitude floatValue], [self.location.longitude floatValue]);
    
}

@end
