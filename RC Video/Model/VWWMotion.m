//
//  SMMotion.m
//  Smile_iOS
//
//  Created by Zakk Hoyt on 1/14/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWMotion.h"

@implementation VWWMotionCluster
-(id)init{
    self = [super init];
    if(self){
    }
    return self;
}


-(id)initWithDictionary:(NSDictionary*)dictionary{
    if(dictionary == nil) return nil;
    self = [super init];
    if(self){
        VWW_LOG_TODO_TASK(@"Init iVars from dictionary keys");
    }
    return self;
}
-(NSDictionary*)dictionary{
    VWW_LOG_TODO_TASK(@"Create dictionary from iVars");
    return @{};
}


-(NSString *)description{
    VWW_LOG_TODO_TASK(@"Create string from iVars");
    return @"";
}


@end

@implementation VWWMotion

#pragma mark Public methods
-(id)init{
    self = [super init];
    if(self){
        self.accelerometer = [[VWWMotionCluster alloc]init];
        self.gyroscope = [[VWWMotionCluster alloc]init];
        self.magnetometer = [[VWWMotionCluster alloc]init];
        self.device = [[VWWMotionCluster alloc]init];
    }
    return self;
}

-(void)setAccelerometerData:(CMAccelerometerData*)accelerometerData{
    VWWMotionCluster *previousData = self.accelerometer;
    self.accelerometer.x = accelerometerData.acceleration.x;
    self.accelerometer.y = accelerometerData.acceleration.y;
    self.accelerometer.z = accelerometerData.acceleration.z;
    self.accelerometer.timeStamp = [NSDate date];
    self.accelerometer.metersPerSecond = [self calculateMetersPerSecondFromPrevioiusData:previousData];
}

-(void)setGyroscopeData:(CMGyroData*)gyroscopeData{
    self.gyroscope.x = gyroscopeData.rotationRate.x;
    self.gyroscope.y = gyroscopeData.rotationRate.y;
    self.gyroscope.z = gyroscopeData.rotationRate.z;
    self.gyroscope.timeStamp = [NSDate date];
    self.gyroscope.metersPerSecond = 0;

}
-(void)setMagnetometerData:(CMMagnetometerData*)magnetometerData{
    self.magnetometer.x = magnetometerData.magneticField.x;
    self.magnetometer.y = magnetometerData.magneticField.y;
    self.magnetometer.z = magnetometerData.magneticField.z;
    self.magnetometer.timeStamp = [NSDate date];
}
-(void)setDeviceData:(CMDeviceMotion*)deviceMotionData{
    self.device.x = deviceMotionData.attitude.pitch;
    self.device.y = deviceMotionData.attitude.roll;
    self.device.z = deviceMotionData.attitude.yaw;
    self.device.timeStamp = [NSDate date];
}

#pragma mark Private methods
-(double)calculateMetersPerSecondFromPrevioiusData:(VWWMotionCluster*)previousData{
    if(previousData == nil){
        return 0;
    }
    
    VWW_LOG_TODO_TASK(@"Implement");
    return 0;
}
@end
