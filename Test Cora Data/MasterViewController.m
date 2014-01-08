//
//  MasterViewController.m
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 03/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "Topic+Doplnky.h"
#import "AddTopicVC.h"
#import "GeoLocator.h"

#import "TwitterFetcher.h"


@interface MasterViewController () <TwitterFetcherDelegate, GeoLocatorDelegate>

@property (atomic) int pocetRefreshAktualizaci;
@property (strong, nonatomic) NSMutableDictionary* geolocators;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end



@implementation MasterViewController



- (NSMutableDictionary *) geolocators {
    
    if (!_geolocators) {
        
        _geolocators = [[NSMutableDictionary alloc] init];
        
    }
    
    return _geolocators;
    
}


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
  
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];

    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    
    
}


- (void) refreshIndicatorCheck {
    
    // TODO refresh indicator funguje nějak divně
    

    if ((self.pocetRefreshAktualizaci > 0) && !self.refreshControl.refreshing) {
        
        [self.refreshControl beginRefreshing];

//        [self.tableView setContentOffset:CGPointMake(0, -100) animated:YES];
        
    } else {
        
        [self.refreshControl endRefreshing];
     
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
    
#ifdef DEBUG
    
        NSLog (@"Pocet refresh aktualizaci: %i", self.pocetRefreshAktualizaci);
    
#endif
    
}

- (void) didStartFetching:(id)sender {
    
    self.pocetRefreshAktualizaci ++;
    [self refreshIndicatorCheck];
    
}

- (void) didFinishFetching:(id)sender {
    
    
    self.pocetRefreshAktualizaci --;

    [self refreshIndicatorCheck];
    
    TwitterFetcher* tf = (TwitterFetcher* )sender;
    

    
    // po stazeni tweetu zkontrolujeme jestli maji platne geolokacni udaje
    
    GeoLocator* gl = [[GeoLocator alloc] init];
                      
    gl.delegate = self;
    
    [gl findGPSofTweetsOfTopic:tf.topic];
    
}



- (void) geolocationWillStart:(GeoLocator *)sender {
    
 //   self.pocetRefreshAktualizaci ++;
    
    [self refreshIndicatorCheck];
    
}


- (void) didFinishGeolocation:(GeoLocator *)sender {
    
//    self.pocetRefreshAktualizaci --;
   
    [self refreshIndicatorCheck];
    
}



#pragma mark - Table View

#define MAX_POCET_TWEETU_PRI_AKTUALIZACI 500


-(void) refreshData {
    
    NSArray* topics = [self.fetchedResultsController fetchedObjects];
    
    for  (Topic* t in topics) {
        
        TwitterFetcher* tf = [TwitterFetcher getTwitterFetcher];
        
        [tf getTweetsForTopic:t count:MAX_POCET_TWEETU_PRI_AKTUALIZACI refresh:YES];
        
        tf.delegate = self;
        
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
 
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        Topic* t = (Topic *)object;

        [[segue destinationViewController] setTitle:t.name];
        [[segue destinationViewController] setTopic:t];
        
    }
    
    if ([[segue identifier] isEqualToString:@"newTopic"]) {
        
        AddTopicVC* vc = [segue destinationViewController];
        vc.delegate = self;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    return 100.0; // vymyslena hodnota, aby to "hezky vypadalo"
    
}


#pragma mark - New topic

-(void) addNewTopicWithName: (NSString* ) name initialTweetCount:(int) count {
    
    Topic* newTopic = [Topic topicWithString:name inManagedObjectContext:self.managedObjectContext];
    
    TwitterFetcher* tf = [TwitterFetcher getTwitterFetcher];
    
    [tf setDelegate:self];
    
    [tf getTweetsForTopic:newTopic count:count refresh:NO];

    
  //  [self.refreshControl beginRefreshing];
    
}





#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Topic" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
  
    
    // TODO - řazení témat podle ID nejnovejsiho tweetu
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
     
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
}


/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    Topic* topic = (Topic *)object;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    
    
    cell.textLabel.text = topic.name;
    
    cell.detailTextLabel.numberOfLines = 3;
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    
    NSString* oldestTweetDate = [formatter stringFromDate:[topic getOldestTweet].date];
    NSString* newestTweetDate = [formatter stringFromDate:[topic getNewestTweet].date];
    
    if (!oldestTweetDate) oldestTweetDate = @"";
    if (!newestTweetDate) newestTweetDate = @"";
    
    
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tweetů s GPS: %i\n od: %@\n do: %@",[topic.tweets count], oldestTweetDate, newestTweetDate];
    
        
}



@end
