//
//  SMMotion.h
//  Smile_iOS
//
//  Created by Zakk Hoyt on 1/14/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//


#import "VWWModelProtocol.h"
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>


@interface VWWMotionCluster : NSObject <VWWModelProtocol>
@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double z;
@property (nonatomic) double metersPerSecond;
@property (nonatomic, strong) NSDate *timeStamp;
@end



@interface VWWMotion : NSObject
@property (nonatomic, strong) VWWMotionCluster *accelerometer;
@property (nonatomic, strong) VWWMotionCluster *gyroscope;
@property (nonatomic, strong) VWWMotionCluster *magnetometer;
@property (nonatomic, strong) VWWMotionCluster *device;
-(void)setAccelerometerData:(CMAccelerometerData*)accelerometerData;
-(void)setGyroscopeData:(CMGyroData*)gyroscopeData;
-(void)setMagnetometerData:(CMMagnetometerData*)magnetometerData;
-(void)setDeviceData:(CMDeviceMotion*)deviceMotionData;
@end
