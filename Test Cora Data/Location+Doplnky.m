//
//  Location+Doplnky.m
//  Demo App
//
//  Created by Vojtěch Šťavík on 09/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "Location+Doplnky.h"

@implementation Location (Doplnky)


+ (Location* ) getNewLocationForString: (NSString* ) name inContext:(NSManagedObjectContext *)context {
    
    Location* newLocation = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
        request.predicate = [NSPredicate predicateWithFormat:@"nameOfLocation = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            
            NSLog(@"Chyba načítání z databáze");
            
        } else if (![matches count]) {
            
            // vytvoříme novou lokaci, GPS nastaveny na 0,0 jako znak Lokace zatím bez GPS
            
            newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                     inManagedObjectContext:context];
            newLocation.nameOfLocation = name;
            newLocation.latitude = 0;
            newLocation.longitude = 0;
            
            
        } else {
            
            newLocation = [matches lastObject];
            
        }
    }
    
    else {
    
        // pokud není vyplněno pole se jménem lokace, vracíme defaultní "prázdnou" lokaci, tweet bude následně při geolokaci smazán
        
        newLocation = [Location getNewLocationForString:EMPTY_LOCATION inContext:context];
        newLocation.latitude = [NSNumber numberWithFloat:INVALID_GPS];
        newLocation.longitude = [NSNumber numberWithFloat:INVALID_GPS];
        
        
    }
    
    return newLocation;
    
}

- (void) deleteThisLocation {

    NSManagedObjectContext* context = self.managedObjectContext;
    
    NSString* name = self.nameOfLocation;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = [NSPredicate predicateWithFormat:@"nameOfLocation = %@", name];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        
        NSLog(@"Chyba načítání z databáze");
        
    } else if (![matches count]) {
        
        NSLog(@"Location nelze smazat protože není v DB :)");
        
    } else {
        
        [context deleteObject:[matches lastObject]];
        
        
    }
    
}


@end
