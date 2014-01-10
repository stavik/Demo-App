//
//  TweetDetailViewController.h
//  Demo App
//
//  Created by Vojtěch Šťavík on 09/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet+Doplnky.h"

@interface TweetDetailViewController : UIViewController

@property (nonatomic, strong) Tweet* tweet;
@property (nonatomic, strong) UIImage* userPhoto;   // abychom ho nestahovali znovu

@end
