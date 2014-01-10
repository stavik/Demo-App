//
//  Location+Doplnky.h
//  Demo App
//
//  Created by Vojtěch Šťavík on 09/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "Location.h"

#define EMPTY_LOCATION @"empty_location"
#define INVALID_GPS -999


@interface Location (Doplnky)

+ (Location* ) getNewLocationForString: (NSString *) name inContext:(NSManagedObjectContext* ) context;

- (void) deleteThisLocation;


@end
