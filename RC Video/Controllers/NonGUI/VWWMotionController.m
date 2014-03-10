//
//  VWWMotionController.m
//  RC Video
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWMotionController.h"
@interface VWWMotionController ()
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) BOOL accelerometerRunning;
@property (nonatomic) BOOL magnetometerRunning;
@property (nonatomic) BOOL gyrosRunning;
@property (nonatomic) BOOL deviceRunning;
@end


@implementation VWWMotionController
#pragma mark Public methods

+(VWWMotionController*)sharedInstance{
    static VWWMotionController *instance;
    if(instance == nil){
        instance = [[VWWMotionController alloc]init];
    }
    return instance;
}

-(id)init{
    self = [super init];
    if(self){
        [self initializeClass];
    }
    return self;
}

+(BOOL)serviceExists{
    VWW_LOG_TODO;
    return YES;
    
}

-(void)startAll{
    [self startAccelerometer];
    [self startGyroscope];
    [self startMagnetometer];
    [self startDevice];
    
}
-(void)stopAll{
    [self stopAccelerometer];
    [self stopGyroscope];
    [self stopMagnetometer];
    [self stopDevice];
    
}

-(void)resetAll{
}


-(void)setUpdateInterval:(NSTimeInterval)updateInterval{
    _updateInterval = updateInterval;
    
    if(self.accelerometerRunning){
        self.motionManager.accelerometerUpdateInterval = self.updateInterval;
    }
    
    if(self.gyrosRunning){
        self.motionManager.gyroUpdateInterval = self.updateInterval;
    }
    
    if(self.magnetometerRunning){
        self.motionManager.magnetometerUpdateInterval = self.updateInterval;
    }
    
    if(self.deviceRunning){
        self.motionManager.deviceMotionUpdateInterval = self.updateInterval;
    }
    
}

#pragma mark Private methods

-(void)initializeClass{
    self.motionManager = [[CMMotionManager alloc]init];
    self.updateInterval = 1/30.0f;
}


-(void)startAccelerometer{
    if(self.accelerometerRunning == YES) return;
    
    self.motionManager.accelerometerUpdateInterval = self.updateInterval;
    
    NSOperationQueue* accelerometerQueue = [[NSOperationQueue alloc] init];
    
    CMAccelerometerHandler accelerometerHandler = ^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self.delegate motionController:self didUpdateAcceleremeters:accelerometerData];
    };
    
    [self.motionManager startAccelerometerUpdatesToQueue:accelerometerQueue withHandler:[accelerometerHandler copy]];
    self.accelerometerRunning = YES;
    VWW_LOG_DEBUG(@"Started Accelerometer");
}


-(void)stopAccelerometer{
    if(self.accelerometerRunning == NO) return;
    
    [self.motionManager stopAccelerometerUpdates];
    self.accelerometerRunning = NO;
    VWW_LOG_DEBUG(@"Stopped Accelerometer");
}

-(void)startGyroscope{
    if(self.gyrosRunning == YES) return;
    
    self.motionManager.gyroUpdateInterval = self.updateInterval;
    
    NSOperationQueue* gyroQueue = [[NSOperationQueue alloc] init];
    
    CMGyroHandler gyroHandler = ^(CMGyroData *gyroData, NSError *error) {
        [self.delegate motionController:self didUpdateGyroscopes:gyroData];
    };
    
    [self.motionManager startGyroUpdatesToQueue:gyroQueue withHandler:[gyroHandler copy]];
    self.gyrosRunning = YES;
    VWW_LOG_DEBUG(@"Started Gyros");
    
}
-(void)stopGyroscope{
    if(self.gyrosRunning == NO) return;
    
    [self.motionManager stopGyroUpdates];
    self.gyrosRunning = NO;
    VWW_LOG_DEBUG(@"Stopped Gyros");
}

-(void)startMagnetometer{
    if(self.magnetometerRunning == YES) return;
    
    self.motionManager.magnetometerUpdateInterval = self.updateInterval;
    
    NSOperationQueue* magnetometerQueue = [[NSOperationQueue alloc] init];
    
    CMMagnetometerHandler magnetometerHandler = ^(CMMagnetometerData *magnetometerData, NSError *error) {
        [self.delegate motionController:self didUpdateMagnetometers:magnetometerData];
    };
    
    [self.motionManager startMagnetometerUpdatesToQueue:magnetometerQueue withHandler:[magnetometerHandler copy]];
    self.magnetometerRunning = YES;
    VWW_LOG_DEBUG(@"Started Magnetometer");
    
}
-(void)stopMagnetometer{
    if(self.magnetometerRunning == NO) return;
    
    [self.motionManager stopMagnetometerUpdates];
    self.magnetometerRunning = NO;
    VWW_LOG_DEBUG(@"Stopped Magnetometer");
}

-(void)startDevice{
    if(self.deviceRunning == YES) return;
    
    self.motionManager.deviceMotionUpdateInterval = self.updateInterval;
    
    NSOperationQueue* deviceQueue = [[NSOperationQueue alloc] init];
    
    CMDeviceMotionHandler deviceHandler = ^(CMDeviceMotion *motion, NSError *error) {
        [self.delegate motionController:self didUpdateAttitude:motion];
    };
    
    [self.motionManager startDeviceMotionUpdatesToQueue:deviceQueue withHandler:deviceHandler];
    self.deviceRunning = YES;
    VWW_LOG_DEBUG(@"Started device motion");
    
}
-(void)stopDevice{
    if(self.deviceRunning == NO) return;
    
    [self.motionManager stopDeviceMotionUpdates];
    self.deviceRunning = NO;
    VWW_LOG_DEBUG(@"Stopped device motion");
}



@end
