//
//  VWWEditVideoTableViewController.m
//  RC Video
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWEditVideoTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VWWAddSubtitleViewController.h"
#import "VWWFileController.h"
static NSString *VWWSegueEditToText = @"VWWSegueEditToText";


@interface VWWEditVideoTableViewController ()
@property (nonatomic, strong) AVAsset *videoAsset;
@end

@implementation VWWEditVideoTableViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:VWWSegueEditToText]){
        VWWAddSubtitleViewController *vc = segue.destinationViewController;
        vc.videoAsset = self.videoAsset;
    }
}

-(void)setVideoURL:(NSURL *)videoURL{
    _videoURL = videoURL;
    
    self.videoAsset = [AVAsset assetWithURL:videoURL];

    if(self.videoAsset){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video Asset Loaded"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not convert URL to Asset"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark IBActions
- (IBAction)printButtonTouchUpInside:(id)sender {
    [VWWFileController printURLsForVideos];
}



#pragma UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        [self performSegueWithIdentifier:VWWSegueEditToText sender:self];
    }
}

@end
