//
//  Topic+Create.m
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 03/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "Topic+Doplnky.h"

@implementation Topic (Doplnky)

+ (Topic *) topicWithString: (NSString *) name inManagedObjectContext: (NSManagedObjectContext *) context {
    
    Topic* newTopic = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topic"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {

            NSLog(@"Chyba načítání z databáze");
            
        } else if (![matches count]) {
            newTopic = [NSEntityDescription insertNewObjectForEntityForName:@"Topic"
                                                         inManagedObjectContext:context];
            newTopic.name = name;
        } else {
            newTopic = [matches lastObject];
        }
    }
    
    return newTopic;
    
}



- (NSArray *) sortTweets: (NSArray *) tweets {
    
    return [tweets sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        Tweet* tweet1 = (Tweet *)obj1;
        Tweet* tweet2 = (Tweet *)obj2;
        
        return [tweet1.id compare:tweet2.id];
        
    }];

    
}


- (Tweet *) getNewestTweet {
    
    NSArray* tweets = [NSArray arrayWithArray:[self.tweets allObjects]];
    
    tweets = [self sortTweets:tweets];
    
    return [tweets lastObject];
    
}


- (Tweet *) getOldestTweet {
   
    NSArray* tweets = [NSArray arrayWithArray:[self.tweets allObjects]];
    
    tweets = [self sortTweets:tweets];
    
    return [tweets firstObject];
    
    
}

- (NSArray *) getSortedTweets {
    
    return [self sortTweets:[NSArray arrayWithArray:[self.tweets allObjects]]];
    
}


- (void) printSortedTweets {
    
    // jen pro potreby debugu
    
    
    NSArray* tweets = [NSArray arrayWithArray:[self.tweets allObjects]];
    
    tweets = [self sortTweets:tweets];
    
    NSLog (@"Tweety dle ID: \n");
    
    for (int i = 0; i < [tweets count]; i++) {
        
        Tweet* t = tweets[i];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm   dd.MM.yyyy"];


        
         NSLog (@"Tweet c.%lli má datum:%@",[t.id longLongValue],[formatter stringFromDate:t.date]);
        

        
    }
    
}

- (BOOL) containsTweet:(Tweet *)tweet {
    
    return [self.tweets containsObject:tweet];
    
}


@end
