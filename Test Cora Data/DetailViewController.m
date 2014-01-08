//
//  DetailViewController.m
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 03/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "Tweet+Doplnky.h"
#import "Topic+Doplnky.h"
#import "AFNetworking.h"

@interface DetailViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray* tweetsForDates;
@property (strong, nonatomic) NSArray* dates;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;


- (void)configureView;
@end

@implementation DetailViewController


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSDate* date = [self.topic getOldestTweet].date;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm   dd.MM.yyyy"];
    
    self.dateLabel.text = [formatter stringFromDate:date];
    
    
    NSArray* test = self.tweetsForDates;  // jen kvůli rychlejší inicializaci

    
    
#ifdef DEBUG
    
    /////// debug - vypis vsech tweetu
    
    [self.topic printSortedTweets];

#endif
    
    
    
}


- (IBAction)valueChanged:(id)sender {
    
#ifdef DEBUG
    
    // debug
    
    NSLog(@"Hodnota slideru: %i", (int)self.slider.value);
    
#endif
    
    BOOL jeStejne = YES;
   
    for (Tweet* t in self.tweetsForDates[(int)self.slider.value]) {
        
        NSArray* anotace = self.mapView.annotations;
        
        if (! [anotace containsObject:t]) jeStejne = NO;
        
    }
    
    
    // pokud se anotace zmeni
    
    if (! jeStejne || ! [self.tweetsForDates[(int)self.slider.value] count])
    {
        
        [self.mapView removeAnnotations:self.mapView.annotations]; // odstranime vsechny stare anotace

        [self.mapView addAnnotations:self.tweetsForDates[(int)self.slider.value]]; // pridame nove, ktere odpovidaji zvolenemu datumu
        
    
    } else {
        
#ifdef DEBUG
        
        // debug
        
        NSLog (@"Stejne anotace");
        
#endif

    }
    
        
    NSDate* date = self.dates[(int)self.slider.value];
    
    
    // aktualizace displeje
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm   dd.MM.yyyy"];
    
    self.dateLabel.text = [formatter stringFromDate:date];
    
}

- (NSArray *) dates {
    
    // cas mezi nejstarsim a nejmladsim tweetem rozdelime na 99 intervalu (slider ma 99 kroku)
    
    if (!_dates) {
        
        NSMutableArray* mutableDates = [[NSMutableArray alloc] initWithCapacity:100];
        
        NSDate* dateOfOldestTweet = [self.topic getOldestTweet].date;
        NSDate* dateOfNewestTweet = [self.topic getNewestTweet].date;
        
#ifdef DEBUG

        // debug
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm   dd.MM.yyyy"];
        
        NSLog(@"Nejstarsi tweet: %@", [formatter stringFromDate:dateOfOldestTweet]);
        NSLog(@"Nejnovejsi tweet: %@", [formatter stringFromDate:dateOfNewestTweet]);
        
        
        ///
#endif
        
        
        NSTimeInterval time = [dateOfNewestTweet  timeIntervalSinceDate:dateOfOldestTweet];
        
        // i<101 protože potřebujeme ještě interval navíc pro nejnovější tweet
        
        for (int i = 0; i < 101; i++) {
            
            NSDate* newDate = [dateOfOldestTweet dateByAddingTimeInterval:(i*time)/100];
            
            [mutableDates addObject:newDate];
            
#ifdef DEBUG
            
            // debug
            
            NSLog(@"Pridano datum: %@", [formatter stringFromDate:newDate]);
#endif
            
        }
        
        _dates = [mutableDates copy];
        
    }
    
    return _dates;
}



- (NSArray*) tweetsForDates {
    
    // pole s tweety pro jednotlivá data. Tweety by šlo filtrovat i dynamicky, ale můžou jich být i tisíce, takže to radši udělám jen jednou pro všechny datumy
    
    if (!_tweetsForDates) {
        
        NSMutableArray* mutableTweetsForDates = [[NSMutableArray alloc] initWithCapacity:100];
       
        
        // i<100 protoze mame 101 datumu, ale mezi nima jen 99 funkcnich intervalu
        
        for (int i = 0; i < 100; i++) {
            
            NSDate* thisDate = self.dates[i];
            NSDate* nextDate = self.dates[i+1];

            NSMutableArray* annotations = [[NSMutableArray alloc] init];
            
            for (Tweet* tweet in self.topic.tweets) {
                
                NSDate* tweetDate = [tweet date];
                
                
                if  (([thisDate compare:tweetDate] == NSOrderedAscending) || ([thisDate compare:tweetDate] == NSOrderedSame) )
                    
                    if (([tweetDate compare:nextDate] == NSOrderedAscending) || ([tweetDate compare:nextDate] == NSOrderedSame))
                        
                        [annotations addObject:tweet];
            
            }
            
            
            [mutableTweetsForDates addObject:[annotations copy]];

            
#ifdef DEBUG
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm   dd.MM.yyyy"];
            NSLog(@"Počet tweetů pro klíč: %i datum: %@ je %i",i, [formatter stringFromDate:self.dates[i]], [annotations count]);
#endif
            
            
        }
    
        _tweetsForDates = [mutableTweetsForDates copy];
        
    }
    
    return _tweetsForDates;
    
    }



#pragma mark - Map View Delegate


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"TweetDetail";
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    if (!view) {
        
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
            view.leftCalloutAccessoryView = imageView;
       
    
        view.image = [UIImage imageNamed:@"tweet-icon"];
        
    }
    
    view.annotation = annotation;
    
    return view;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

    UIImageView *imageView = nil;
    
    if ([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        imageView = (UIImageView *)view.leftCalloutAccessoryView;
    }
    
    if (imageView) {
        
        Tweet* tweet = nil;
        
        if ([view.annotation isKindOfClass:[Tweet class]]) {
            
            tweet = (Tweet *)view.annotation;
            
        }
        
        if (tweet) {
            
            NSURL *imageURL = [NSURL URLWithString:tweet.imageURL];
            
            NSURLRequest* urlRequest = [NSURLRequest requestWithURL:imageURL];
            
            AFHTTPRequestOperation *postOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
            
            postOperation.responseSerializer = [AFImageResponseSerializer serializer];
            
            [postOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                imageView.image = responseObject;
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Image dowloading error: %@", error);
            }];
            
            [postOperation start];
        }
    }


}



#pragma mark - Managing the detail item



- (void)configureView
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    self.mapView.delegate=self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
