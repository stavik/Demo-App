//
//  MasterViewController.h
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 03/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


- (void) addNewTopicWithName: (NSString* )name initialTweetCount: (int)count ;
- (void) backgroundRefreshDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler ;


@end
