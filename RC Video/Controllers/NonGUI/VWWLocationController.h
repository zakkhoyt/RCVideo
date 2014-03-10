//
//  VWWLocationController.h
//  RC Video
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

static NSString *SMLocationControllerLocationKey = @"location";
static NSString *SMLocationControllerHeadingKey = @"heading";

@class VWWLocationController;

@protocol VWWLocationControllerDelegate <NSObject>
-(void)locationController:(VWWLocationController*)sender didUpdateLocations:(NSArray*)locations;
-(void)locationController:(VWWLocationController *)sender didUpdateHeading:(CLHeading*)heading;
@end



@interface VWWLocationController : NSObject
+(VWWLocationController*)sharedInstance;
-(void)start;
-(void)stop;

@property (nonatomic, weak) id <VWWLocationControllerDelegate>delegate;

@end
