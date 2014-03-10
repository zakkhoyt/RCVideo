//
//  VWWDataLogController.m
//  RC Video
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWDataLogController.h"
#import "VWWLocationController.h"
#import "VWWMotionController.h"





@interface VWWDataLogController () <VWWLocationControllerDelegate, VWWMotionControllerDelegate>
@property dispatch_queue_t dataQueue;
@property (nonatomic, strong) VWWLocationController *locationController;
@property (nonatomic, strong) VWWMotionController *motionController;
@property (nonatomic, strong) CMAccelerometerData *accelerometers;
@property (nonatomic, strong) CMGyroData *gyroscopes;
@property (nonatomic, strong) CMMagnetometerData *magnetometers;
@property (nonatomic, strong) CMDeviceMotion* attitude;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) CLHeading *heading;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation VWWDataLogController
+(VWWDataLogController*)sharedInstance{
    static VWWDataLogController *instance;
    if(instance == nil){
        instance = [[VWWDataLogController alloc]init];
    }
    return instance;
}

-(id)init{
    self = [super init];
    if(self){
        self.dataQueue = dispatch_queue_create("com.vaporwarewolf.dataQueue", NULL);
        self.locationController = [VWWLocationController sharedInstance];
        self.locationController.delegate = self;
        self.motionController = [VWWMotionController sharedInstance];
        self.motionController.delegate = self;
        self.motionController.updateInterval = 1/5.0f;
        self.data = [[NSMutableArray alloc]initWithCapacity:1200]; // at two/second this is 10 minutes
        
        [self.motionController startAll];
        [self.locationController start];

    }
    return self;
}

-(void)start{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1/5.0f target:self selector:@selector(logDataPoint) userInfo:Nil repeats:YES];
}
-(void)stop{
//    [self.motionController stopAll];
//    [self.locationController stop];
    
    [self.timer invalidate];
    _timer = nil;
}

-(void)calibrate{
    VWW_LOG_TODO;
}


#pragma mark Private methods
-(void)logDataPoint{
    @autoreleasepool {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        if(self.location){
            [dictionary setObject:self.location forKey:VWWDataLogControllerLocationKey];
        }
        if(self.heading){
            [dictionary setObject:self.heading forKey:VWWDataLogControllerHeadingKey];
        }
        if(self.accelerometers){
            [dictionary setObject:self.accelerometers forKey:VWWDataLogControllerAccelermetersKey];
        }
        if(self.gyroscopes){
            [dictionary setObject:self.gyroscopes forKey:VWWDataLogControllerGyroscopesKey];
        }
        if(self.magnetometers){
            [dictionary setObject:self.magnetometers forKey:VWWDataLogControllerGyroscopesKey];
        }
        if(self.attitude){
            [dictionary setObject:self.attitude forKey:VWWDataLogControllerAttitudeKey];
        }
        
        [self.data addObject:dictionary];
        [self.delegate dataLogController:self didLogDataPoint:dictionary];
        
    }

}


#pragma mark VWWMotionControllerDelegate
-(void)motionController:(VWWMotionController*)sender didUpdateAcceleremeters:(CMAccelerometerData*)accelerometers{
    self.accelerometers = accelerometers;
}
-(void)motionController:(VWWMotionController*)sender didUpdateGyroscopes:(CMGyroData*)gyroscopes{
    self.gyroscopes = gyroscopes;
}
-(void)motionController:(VWWMotionController*)sender didUpdateMagnetometers:(CMMagnetometerData*)magnetometers{
    self.magnetometers = magnetometers;
}
-(void)motionController:(VWWMotionController*)sender didUpdateAttitude:(CMDeviceMotion*)attitude{
    self.attitude = attitude;
}



#pragma mark VWWLocationControllerDelegate
-(void)locationController:(VWWLocationController*)sender didUpdateLocations:(NSArray*)locations{
    // delegate parent ensures that there will be at least 1 location.
    self.location = locations[0];
}
-(void)locationController:(VWWLocationController *)sender didUpdateHeading:(CLHeading*)heading{
    self.heading = heading;
}

@end
