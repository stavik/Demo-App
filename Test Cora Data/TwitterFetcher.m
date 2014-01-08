//
//  TwitterFetcher.m
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 03/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "TwitterFetcher.h"
#import "AFNetworking.h"
#import "Topic+Doplnky.h"
#import "Tweet+Doplnky.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>





#define TWITTER_CONSUMER_KEY @"tRZcOz0PDF3SQYDMfhDZQ"
#define TWITTER_CONSUMER_SECRET @"OPuiaVhS7CODM6zNiY97Byq2wX2mdmQ0I4Z5zrKM7oU"
#define TWITTER_AUTH_ADRESA @"https://api.twitter.com/oauth2/token"
#define TWITTER_SEARCH_ADRESA @"https://api.twitter.com/1.1/search/tweets.json"

@interface TwitterFetcher ()

@property (strong, nonatomic) NSString* bearerToken;
@property (nonatomic) int pocetNahranychTweetu;
@property (nonatomic) int pocetPozadovanychTweetu;
@property (nonatomic) int pocetAktualnePozadovanychTweetu;
@property (nonatomic) BOOL jsouTweety;
@property (nonatomic) BOOL isRefresh;
@property (nonatomic, strong) NSMutableArray* nahraneTweety;



@end

@implementation TwitterFetcher


+ (TwitterFetcher *) getTwitterFetcher {
    
    
    // static TwitterFetcher* myFetcher = nil;
    // promyslet fetcher, aby fungoval asynchronne!
    
    
    TwitterFetcher* myFetcher = nil;
    
    myFetcher = [[TwitterFetcher alloc] init];
    
    return myFetcher;
        
}


- (NSString *) bearerToken {
    
       return _bearerToken;
    
}



- (NSMutableArray *) nahraneTweety {
    
    if (!_nahraneTweety) {
        _nahraneTweety = [[NSMutableArray alloc] init];
    }
    
    return _nahraneTweety;
    
}


- (void)getTweetsForTopic:(Topic *)newTopic count:(NSInteger)count refresh:(BOOL)refresh {
    
    // myslenka - pokud je refresh, pocet nactenych tweetu by mel byt max
    
    
    [self.delegate didStartFetching:self];
    
    
    self.topic = newTopic;
    self.pocetPozadovanychTweetu = count;
    self.pocetAktualnePozadovanychTweetu = 0;
    self.pocetNahranychTweetu = 0;
    self.jsouTweety = YES;
    self.isRefresh = refresh;

    long long int sinceID = 0;
    
#ifdef DEBUG
    
    
    if (self.isRefresh) {
        
        NSLog(@"Nejnovejsi ID %llu", [[self.topic getNewestTweet].id longLongValue]);
        NSLog(@"Nejnovejsi ID %llu", [[self.topic getOldestTweet].id longLongValue]);
        
    }

#endif
    
    
    // priprava autorizacniho tokenu

    NSString* tokenCredentials = TWITTER_CONSUMER_KEY;
    tokenCredentials = [tokenCredentials stringByAppendingString:@":"];
    tokenCredentials = [tokenCredentials stringByAppendingString:TWITTER_CONSUMER_SECRET];
    
    NSData* tokenCredentialsData = [tokenCredentials dataUsingEncoding:NSUTF8StringEncoding];
    
    tokenCredentials = [tokenCredentialsData  base64EncodedStringWithOptions:0];
    NSString* basic = @"Basic ";
    tokenCredentials = [basic stringByAppendingString:tokenCredentials];
    
    
    NSURL *authURL = [NSURL URLWithString:TWITTER_AUTH_ADRESA];
    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL: authURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:tokenCredentials forHTTPHeaderField:@"Authorization"];
    
    NSDictionary* parameters = [[NSDictionary alloc] initWithObjectsAndKeys:@"client_credentials", @"grant_type", nil];
    
    [manager POST:TWITTER_AUTH_ADRESA parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.bearerToken = @"Bearer ";
        self.bearerToken = [self.bearerToken stringByAppendingString:[responseObject objectForKey:@"access_token"]];
        
        [self loadTweetsSinceID:sinceID maxID:0];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Chyba: \n");
        NSLog([error description]);
    }];


    
}

#define MAX_POCET_TWEETU 100


- (void) loadTweetsSinceID:(long long int) sinceID maxID:(long long int) maxID {
    
    
    NSString* hledanyVyraz = self.topic.name;
    
    
    NSURL *authURL = [NSURL URLWithString:TWITTER_SEARCH_ADRESA];
    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL: authURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:self.bearerToken forHTTPHeaderField:@"Authorization"];
    
    NSDictionary* parameters = nil;
    
    self.pocetAktualnePozadovanychTweetu  = self.pocetPozadovanychTweetu - self.pocetNahranychTweetu;
    
    if (self.pocetAktualnePozadovanychTweetu > MAX_POCET_TWEETU) self.pocetAktualnePozadovanychTweetu = MAX_POCET_TWEETU;
    
    if (self.isRefresh) self.pocetAktualnePozadovanychTweetu = MAX_POCET_TWEETU;

    
    if (!sinceID && !maxID) {
        // nacteme vsechny pozadovane tweety
        parameters = [[NSDictionary alloc] initWithObjectsAndKeys:hledanyVyraz, @"q", [NSNumber numberWithInt:self.pocetAktualnePozadovanychTweetu], @"count", nil];
        
        
    } else if (maxID && !sinceID) {
        
        // nacteme tweety starsi nez je tweet v parametru
        
        parameters = [[NSDictionary alloc] initWithObjectsAndKeys:hledanyVyraz, @"q", [NSNumber numberWithInt:self.pocetAktualnePozadovanychTweetu], @"count", [NSNumber numberWithLongLong:maxID], @"max_id",  nil];
        
    } else if (maxID && sinceID) {
    
        // nacteme tweety od tweetu do tweetu v parametru
    
        parameters = [[NSDictionary alloc] initWithObjectsAndKeys:hledanyVyraz, @"q", [NSNumber numberWithInt:self.pocetAktualnePozadovanychTweetu], @"count", [NSNumber numberWithLongLong:(sinceID+1)], @"since_id", [NSNumber numberWithLongLong:maxID], @"max_id",  nil];
    }
    
    
#ifdef DEBUG
    
    // debug
    
    NSLog (@"Už načteno: %i     Aktuálně požadováno: %i      z celkových: %i",[self.nahraneTweety count], self.pocetAktualnePozadovanychTweetu, self.pocetPozadovanychTweetu);
    
#endif
    
    
    
    [manager GET:TWITTER_SEARCH_ADRESA parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* loadedTweets = nil;
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            loadedTweets = (NSDictionary *)responseObject;
        }
       
       
       [self saveTweets: loadedTweets];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Chyba načítání tweetů: \n");
        
        NSLog([error description]);
 
        
        
    }];
}



- (void) saveTweets: (NSDictionary *) tweets {
    
    if (!tweets) {
        NSLog(@"Chyba převodu na Dictionary");
        return;
    }
    
    NSArray* tweety = [tweets valueForKeyPath:@"statuses"];
    
    int pocet = [tweety count];
    
    if (!pocet) {
        
        // není více tweetů ke stažení
        
        self.jsouTweety = NO;
        
    }
    
    
    
    self.pocetNahranychTweetu += pocet; // jelikoz jde nahrat max 100 tweetu naraz, muze se stahovani opakovat nekolikrat
    
    
    for (NSDictionary* t in tweety) {
        
        AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext* context = delegate.managedObjectContext;
        
        long long int id = [[t objectForKey:@"id_str"] longLongValue];
        
        
        
        // testujeme, jestli už je objekt v DB (vrací nil)  , pokud ano, končíme aktualizaci, protoze uz nejsou zadne nove tweety
        
        Tweet* newTweet = [Tweet newTweetWithID:id InManagedObjectContext:context];
        
        if (newTweet) {
        
            __block NSDate *detectedDate;
            
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllTypes error:nil];
            
            [detector enumerateMatchesInString:[t objectForKey:@"created_at"]
                                       options:kNilOptions
                                         range:NSMakeRange(0, [[t objectForKey:@"created_at"] length])
                                    usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
             { detectedDate = result.date; }];
            
            
            newTweet.date = detectedDate;
            newTweet.text = [t objectForKey:@"text"];
            
            
            NSDictionary* userInfo = [t objectForKey:@"user"];
            
            newTweet.user = [userInfo objectForKey:@"name"];
            newTweet.location = [userInfo objectForKey:@"location"];
            newTweet.imageURL = [userInfo objectForKey:@"profile_image_url"];
            
/*
             NSLog (@"\n\nPridan novy Tweet: \n");
             NSLog(newTweet.date.description);
             //     NSLog(newTweet.imageURL);
             
             if ([newTweet.location isEqualToString:@""]) {
             
             NSLog(@"Lokace není");
             
             } else {
             NSLog(@"Lokace: %@", newTweet.location);
             
             }
             
             NSLog(newTweet.text);
             NSLog(newTweet.user);
             NSLog(@"%lli",[newTweet.id longLongValue]);
             
*/
            
            
            [self.nahraneTweety addObject:newTweet];   // pole s nove stazenymi tweety, muze se lisit od vsech tweetu, pokud jen probiha aktualizace

#ifdef DEBUG
            
            // debug
            
            NSLog (@"Pocet nove stazenych tweetu pro tema %@ je :%i", self.topic.name,[self.nahraneTweety count]);
            
#endif
            
        }
        
        else {
            
            self.jsouTweety = NO;
            
        }
    }
    

    
    // projedeme pole s novymi tweety abychom nasli nejnovejsi a nejstarsi
    
    self.nahraneTweety = [[self.nahraneTweety sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        Tweet* tweet1 = (Tweet *)obj1;
        Tweet* tweet2 = (Tweet *)obj2;
        
        return [tweet1.id compare:tweet2.id];   }] mutableCopy];
    
    
    Tweet* nejstarsiNovyTweet = [self.nahraneTweety firstObject];
    
    
    // pokud neni stazeny pozadovany pocet tweetu a jsou nove tweety stahujeme dal
    
    if (self.jsouTweety && (self.pocetNahranychTweetu < self.pocetPozadovanychTweetu)) {
        
            [self loadTweetsSinceID:0 maxID:[nejstarsiNovyTweet.id longLongValue] - 1];
            
            return;
    }
    
    
    
    // pokud je refresh, stahujeme dokud jsou tweety
    
    if (self.isRefresh && self.jsouTweety) {
        
        [self loadTweetsSinceID:[[self.topic getNewestTweet].id longLongValue] maxID:[nejstarsiNovyTweet.id longLongValue] - 1]; // -1 znamena do daneho tweetu
        
        return;
        
    }
    
    [self finish];
    
}

- (void) finish {
  
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];

    
    [self.topic addTweets:[NSSet setWithArray:self.nahraneTweety]];
    
    [appDelegate saveContext];
    
    [self.delegate didFinishFetching:self];

    
#ifdef DEBUG
    
    
    NSLog (@"Nejmladsi tweet:%@", [self.topic getNewestTweet].date.description);
    
    NSLog (@"Nejstarsi tweet:%@",  [self.topic getOldestTweet].date.description);

    
    
    Tweet* nejstarsiNovyTweet = [self.nahraneTweety firstObject];
    Tweet* nejmladsiNovyTweet = [self.nahraneTweety lastObject];
    
    NSLog (@"Nejmladsi novy tweet:%@", nejmladsiNovyTweet.date.description);
    
    NSLog (@"Nejstarsi novy tweet:%@",  nejstarsiNovyTweet.date.description);

#endif
    
}

@end
