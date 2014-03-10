//
//  VWWDataLogController.h
//  RC Video
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWWLocationController.h"
#import "VWWMotionController.h"


static NSString *VWWDataLogControllerAccelermetersKey = @"acc";
static NSString *VWWDataLogControllerGyroscopesKey = @"gyro";
static NSString *VWWDataLogControllerMagnetometersKey = @"mag";
static NSString *VWWDataLogControllerAttitudeKey = @"att";
static NSString *VWWDataLogControllerXKey = @"x";
static NSString *VWWDataLogControllerYKey = @"y";
static NSString *VWWDataLogControllerZKey = @"z";

static NSString *VWWDataLogControllerLocationKey = @"loc";
static NSString *VWWDataLogControllerLatitudeKey = @"lat";
static NSString *VWWDataLogControllerLongitudeKey = @"lon";
static NSString *VWWDataLogControllerAltitudeKey = @"alt";

static NSString *VWWDataLogControllerHeadingKey = @"head";

static NSString *VWWDataLogControllerDateKey = @"date";

@class VWWDataLogController;

@protocol VWWDataLogControllerDelegate <NSObject>
-(void)dataLogController:(VWWDataLogController*)sender didLogDataPoint:(NSDictionary*)dataPoint;
@end

@interface VWWDataLogController : NSObject
+(VWWDataLogController*)sharedInstance;
@property (nonatomic, weak) id <VWWDataLogControllerDelegate> delegate;
-(void)start;
-(void)stop;
-(void)calibrate;
@end
