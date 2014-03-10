//
//  VWWMotionController.h
//  RC Video
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@class VWWMotionController;

@protocol VWWMotionControllerDelegate <NSObject>
-(void)motionController:(VWWMotionController*)sender didUpdateAcceleremeters:(CMAccelerometerData*)accelerometers;
-(void)motionController:(VWWMotionController*)sender didUpdateGyroscopes:(CMGyroData*)gyroscopes;
-(void)motionController:(VWWMotionController*)sender didUpdateMagnetometers:(CMMagnetometerData*)magnetometers;
-(void)motionController:(VWWMotionController*)sender didUpdateAttitude:(CMDeviceMotion*)attitude;
@end


@interface VWWMotionController : NSObject
+(VWWMotionController*)sharedInstance;
@property (nonatomic, weak) id <VWWMotionControllerDelegate> delegate;
@property (nonatomic) NSTimeInterval updateInterval;
-(void)startAll;
-(void)stopAll;
-(void)resetAll;
@end
