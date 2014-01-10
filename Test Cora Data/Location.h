//
//  Location.h
//  Demo App
//
//  Created by Vojtěch Šťavík on 09/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * nameOfLocation;
@property (nonatomic, retain) NSSet *belongsTo;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addBelongsToObject:(Tweet *)value;
- (void)removeBelongsToObject:(Tweet *)value;
- (void)addBelongsTo:(NSSet *)values;
- (void)removeBelongsTo:(NSSet *)values;

@end
