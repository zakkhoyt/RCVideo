//
//  VWWDefaultTableViewController.m
//  RC Video
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWDefaultTableViewController.h"

@interface VWWDefaultTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *logGPSSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *logHeadingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *logAccelerometersSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *logGyroscopesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *logMagnetometersSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *logAttitudeSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *offsetSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSegment;
@end

@implementation VWWDefaultTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.logGPSSwitch.on = [VWWUserDefaults logGPS];
    self.logHeadingSwitch.on = [VWWUserDefaults logHeading];
    self.logAccelerometersSwitch.on = [VWWUserDefaults logAccelerometers];
    self.logGyroscopesSwitch.on = [VWWUserDefaults logGyroscopes];
    self.logMagnetometersSwitch.on = [VWWUserDefaults logMagnetometers];
    self.logAttitudeSwitch.on = [VWWUserDefaults logAttitude];
    self.offsetSegment.selectedSegmentIndex = [VWWUserDefaults offset];
    self.unitsSegment.selectedSegmentIndex = [VWWUserDefaults units];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



#pragma mark IBActions
- (IBAction)logGPSSwitchValueChanged:(UISwitch*)sender {
    [VWWUserDefaults setLogGPS:sender.on];
}
- (IBAction)logHeadingSwitchValueChanged:(UISwitch*)sender {
    [VWWUserDefaults setLogHeading:sender.on];
}
- (IBAction)logAccelerometersSwitchValueChanged:(UISwitch*)sender {
    [VWWUserDefaults setLogAccelerometers:sender.on];
}
- (IBAction)logGyroscopesSwitchValueChanged:(UISwitch*)sender {
    [VWWUserDefaults setLogGyroscopes:sender.on];
}
- (IBAction)logMagnetometersSwitchValueChanged:(UISwitch*)sender {
    [VWWUserDefaults setLogMagnetometers:sender.on];
}
- (IBAction)logAttitudeSwitchValueChanged:(UISwitch*)sender {
    [VWWUserDefaults setLogAttitude:sender.on];
}
- (IBAction)offsetSegmentValueChanged:(UISegmentedControl*)sender {
    [VWWUserDefaults setOffset:(VWWOffsetType)sender.selectedSegmentIndex];
}
- (IBAction)unitsSegmentValueChanged:(UISegmentedControl*)sender {
    [VWWUserDefaults setUnits:(VWWUnitType)sender.selectedSegmentIndex];
}



@end
