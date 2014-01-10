//
//  TweetDetailViewController.m
//  Demo App
//
//  Created by Vojtěch Šťavík on 09/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "Location+Doplnky.h"

@interface TweetDetailViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *tweetText;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *gpsLabel;

@end

@implementation TweetDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    
    self.tweetText.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:225.0/255.0 blue:250.0/255.0 alpha:1.0];
    
    
    self.userImageView.image = self.userPhoto;
    
    self.userNameLabel.text = self.tweet.user;
    
    self.tweetText.text = self.tweet.text;
    
    self.locationLabel.text = self.tweet.location.nameOfLocation;
    
    float latitude = [self.tweet.location.latitude floatValue];
    float longitude = [self.tweet.location.longitude floatValue];
    
    self.gpsLabel.text = [NSString stringWithFormat:@"%.4f   %.4f", latitude , longitude];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm   dd.MM.yyyy"];
    
    self.dateLabel.text = [formatter stringFromDate:self.tweet.date];
    
    
    
}

@end
