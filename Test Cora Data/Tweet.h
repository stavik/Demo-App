//
//  Tweet.h
//  Demo App
//
//  Created by Vojtěch Šťavík on 09/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, Topic;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) Topic *belongsTo;
@property (nonatomic, retain) Location *location;

@end
