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
#import "Location+Doplnky.h"
#import "TweetDetailViewController.h"

@interface DetailViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray* tweetsForDates;
@property (strong, nonatomic) NSArray* dates;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)configureView;
@end

@implementation DetailViewController

- (void) viewDidLoad {

    [super viewDidLoad];
    
    [self configureView];
    
    self.mapView.delegate=self;
        
    MKCoordinateRegion zoomRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(50.0755381, 14.43780049999998), MKCoordinateSpanMake(90, 180)); // Praha
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:zoomRegion];
    [self.mapView setRegion:adjustedRegion animated:NO];
    
    NSDate* date = [self.topic getOldestTweet].date;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm   dd.MM.yyyy"];
    
    self.dateLabel.text = [formatter stringFromDate:date];
    
    
    [self inicializaceTweetu];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    

    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void) inicializaceTweetu {
    
    [self.activityIndicator startAnimating];
    
    self.slider.enabled = NO;
    
    
    dispatch_async(dispatch_queue_create ("cz.vojtechstavik.demoapp.nacitanitweetu", NULL), ^{
    
    
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
                    
                    if (! ([tweet.location.longitude floatValue] == 0 || [tweet.location.latitude floatValue] == 0))  // tweet ktery jeste neprosel geolokaci nepridavame
                        
                        [annotations addObject:tweet];
            
        }
        
        
        [mutableTweetsForDates addObject:[annotations copy]];
        
    }
    
    self.tweetsForDates = [mutableTweetsForDates copy];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self.activityIndicator stopAnimating];
            
            self.slider.enabled = YES;
            
            self.slider.value = 1;
            
            [self valueChanged:self.slider];
            
        });
    
    });
    
    
    
    
}

- (IBAction)valueChanged:(id)sender {
    
    
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
        
       
        
        NSTimeInterval time = [dateOfNewestTweet  timeIntervalSinceDate:dateOfOldestTweet];
        
        // i<101 protože potřebujeme ještě interval navíc pro nejnovější tweet
        
        for (int i = 0; i < 101; i++) {
            
            NSDate* newDate = [dateOfOldestTweet dateByAddingTimeInterval:(i*time)/100];
            
            [mutableDates addObject:newDate];
            

            
        }
        
        _dates = [mutableDates copy];
        
    }
    
    return _dates;
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
            
            UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            view.rightCalloutAccessoryView = disclosureButton;
            
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

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [self performSegueWithIdentifier:@"ShowDetailOfTweet" sender:view];
    
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([sender isKindOfClass:[MKAnnotationView class]]) {
   
    
        MKAnnotationView* view = (MKAnnotationView *)sender;
    
        if ([[segue identifier] isEqualToString:@"ShowDetailOfTweet"]) {
        
            if ([segue.destinationViewController isKindOfClass:[TweetDetailViewController class]]) {
            
                TweetDetailViewController* tdvc = (TweetDetailViewController* )segue.destinationViewController;
            
                tdvc.tweet = view.annotation;
                tdvc.userPhoto = ((UIImageView *)view.leftCalloutAccessoryView).image;
                
            }
        }
        
    }
    
}



- (void)configureView
{

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
