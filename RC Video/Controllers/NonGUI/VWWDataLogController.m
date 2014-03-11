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

@property (nonatomic, strong) CLLocation *calibrateLocation;
@property (nonatomic, strong) CLHeading *calibrateHeading;
@property (nonatomic, strong) CMAccelerometerData *calibrateAccelerometers;
@property (nonatomic, strong) CMGyroData *calibrateGyroscopes;
@property (nonatomic, strong) CMMagnetometerData *calibrateMagnetometers;
@property (nonatomic, strong) CMDeviceMotion* calibrateAttitude;

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
        self.motionController.updateInterval = 1/(float)[VWWUserDefaults updateFrequency];
        self.data = [[NSMutableArray alloc]initWithCapacity:1200]; // at two/second this is 10 minutes
        
        [self.motionController startAll];
        [self.locationController start];
        
    }
    return self;
}

-(void)start{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1/(float)[VWWUserDefaults updateFrequency] target:self selector:@selector(logDataPoint) userInfo:Nil repeats:YES];
}
-(void)stop{
    //    [self.motionController stopAll];
    //    [self.locationController stop];
    
    [self.timer invalidate];
    _timer = nil;
}

-(void)calibrate{
    if(self.location){
        self.calibrateLocation = [self.location copy];
    }
    if(self.heading){
        self.calibrateHeading = [self.heading copy];
    }
    if(self.accelerometers){
        self.calibrateAccelerometers = [self.accelerometers copy];
    }
    if(self.gyroscopes){
        self.calibrateGyroscopes = [self.gyroscopes copy];
    }
    if(self.magnetometers){
        self.calibrateMagnetometers = [self.magnetometers copy];
    }
    if(self.attitude){
        self.calibrateAttitude = [self.attitude copy];
    }
}




#pragma mark Private methods
-(void)logDataPoint{
    @autoreleasepool {
        // Create log entry
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
        
        // Update data log string for delegate
        NSMutableString *logString = [[NSMutableString alloc]initWithString:@""];
        if(self.location){

            // Latitude/Longitude or distance
            if([VWWUserDefaults logGPS]){
                [logString appendFormat:@"--------------- GPS ----------------\n"];
                if([VWWUserDefaults offset] == VWWOffsetTypeAbsolute){
                    [logString appendFormat:@"latitude: %.4f\n", self.location.coordinate.latitude];
                    [logString appendFormat:@"longitude: %.4f\n", self.location.coordinate.longitude];
                } else if([VWWUserDefaults offset] == VWWOffsetTypeDelta){
                    float deltaCoordinate = [VWWUtilities metersBetweenPointA:self.calibrateLocation pointB:self.location];
                    if([VWWUserDefaults units] == VWWUnitTypeMeters){
                        [logString appendFormat:@"distance: %.1fm\n", deltaCoordinate];
                    } else if([VWWUserDefaults units] == VWWUnitTypeFeet){
                        deltaCoordinate = [VWWUtilities metersToFeet:deltaCoordinate];
                        [logString appendFormat:@"distance: %.1ff\n", deltaCoordinate];
                    }
                }
                
                // Altitude
                if([VWWUserDefaults offset] == VWWOffsetTypeAbsolute){
                    [logString appendFormat:@"altitude: %.1fm\n", self.location.altitude];
                } else if([VWWUserDefaults offset] == VWWOffsetTypeDelta){
                    float deltaAltitude = self.location.altitude - self.calibrateLocation.altitude;
                    if([VWWUserDefaults units] == VWWUnitTypeMeters){
                        [logString appendFormat:@"altitude: %.1fm\n", deltaAltitude];
                    } else if([VWWUserDefaults units] == VWWUnitTypeFeet){
                        deltaAltitude = [VWWUtilities metersToFeet:deltaAltitude];
                        [logString appendFormat:@"altitude: %.1ff\n", deltaAltitude];
                    }
                }
            }
            
            // Heading
            if([VWWUserDefaults logHeading]){
                if(self.heading){
                    [logString appendFormat:@"------------- Heading --------------\n"];
                    [logString appendFormat:@"heading: %f\n", self.heading.magneticHeading];
                }
            }

            
            // Accelerometers
            if([VWWUserDefaults logAccelerometers]){
                [logString appendFormat:@"---------- Accelerometers ----------\n"];
                [logString appendFormat:@"x: %.4f\n", self.accelerometers.acceleration.x];
                [logString appendFormat:@"y: %.4f\n", self.accelerometers.acceleration.y];
                [logString appendFormat:@"z: %.4f\n", self.accelerometers.acceleration.z];
            }
            
            // Gyroscopes
            if([VWWUserDefaults logGyroscopes]){
                [logString appendFormat:@"------------ Gyroscopes ------------\n"];
                [logString appendFormat:@"x: %.4f\n", self.gyroscopes.rotationRate.x];
                [logString appendFormat:@"y: %.4f\n", self.gyroscopes.rotationRate.y];
                [logString appendFormat:@"z: %.4f\n", self.gyroscopes.rotationRate.z];
            }

            // Magnetometers
            if([VWWUserDefaults logMagnetometers]){
                [logString appendFormat:@"---------- Magnetometers -----------\n"];
                [logString appendFormat:@"x: %.4f\n", self.magnetometers.magneticField.x];
                [logString appendFormat:@"y: %.4f\n", self.magnetometers.magneticField.y];
                [logString appendFormat:@"z: %.4f\n", self.magnetometers.magneticField.z];
            }

            
            // Attitude
            if([VWWUserDefaults logAttitude]){
                [logString appendFormat:@"------------- Attitude -------------\n"];
//                [logString appendFormat:@"Att.x: %.4f\n", self.magnetometers.magneticField.x];
//                [logString appendFormat:@"Att.y: %.4f\n", self.magnetometers.magneticField.y];
//                [logString appendFormat:@"Att.z: %.4f\n", self.magnetometers.magneticField.z];
            }

            
            
            
        }
        
        
        // Call delegate
        [self.delegate dataLogController:self didUpdateLogString:logString];
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
