//
//  VWWCaptureFromVideoViewController.m
//  ColorBlind2
//
//  Created by Zakk Hoyt on 12/2/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//
// Some good stuff about augmented reality here: http://cmgresearch.blogspot.com/2010/10/augmented-reality-on-iphone-with-ios40.html
// A forum post about AVAssetWriter: http://stackoverflow.com/questions/4149963/this-code-to-write-videoaudio-through-avassetwriter-and-avassetwriterinputs-is
// A forum post about orientation: http://stackoverflow.com/questions/3561738/why-avcapturesession-output-a-wrong-orientation

#import "VWWCaptureVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VWWDataLogController.h"
#import "NSTimer+Blocks.h"
#import "VWWEditVideoTableViewController.h"
#import "VWWFileController.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VWWFileController.h"

#define BYTES_PER_PIXEL 4


static NSString *VWWSegueRecordToEdit = @"VWWSegueRecordToEdit";

@interface VWWCaptureVideoViewController () <VWWDataLogControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
// Class

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UISwitch *overlaySwitch;
@property (weak, nonatomic) IBOutlet UILabel *overlayLabel;
@property (nonatomic, strong) VWWDataLogController *dataLogController;


// AVFoundation
//@property (readwrite) Float64 videoFrameRate;
//@property (readwrite) CMVideoDimensions videoDimensions;
//@property (readwrite) CMVideoCodecType videoType;
//@property (readwrite, getter=isRecording) BOOL recording;
//@property (readwrite) AVCaptureVideoOrientation videoOrientation;



@end

@implementation VWWCaptureVideoViewController{
    NSMutableArray *previousSecondTimestamps;
	Float64 videoFrameRate;
	CMVideoDimensions videoDimensions;
	CMVideoCodecType videoType;
    
	AVCaptureSession *captureSession;
	AVCaptureConnection *audioConnection;
	AVCaptureConnection *videoConnection;
    AVCaptureVideoPreviewLayer *previewLayer;
	CMBufferQueueRef previewBufferQueue;
	
	NSURL *movieURL;
	AVAssetWriter *assetWriter;
	AVAssetWriterInput *assetWriterAudioIn;
	AVAssetWriterInput *assetWriterVideoIn;
	dispatch_queue_t movieWritingQueue;
    
	AVCaptureVideoOrientation referenceOrientation;
	AVCaptureVideoOrientation videoOrientation;
    
	// Only accessed on movie writing queue
    BOOL readyToRecordAudio;
    BOOL readyToRecordVideo;
	BOOL recordingWillBeStarted;
	BOOL recordingWillBeStopped;
    
	BOOL recording;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // AVFoundation
    previousSecondTimestamps = [[NSMutableArray alloc] init];
    referenceOrientation = (AVCaptureVideoOrientation)UIDeviceOrientationPortrait;
    
    // The temporary path for the video before saving it to the photo album
    NSString *myPathDocs =  [[VWWFileController pathForDocumentsDirectory] stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"RosyVideo-%d.mov",arc4random() % 1000]];
    movieURL = [NSURL fileURLWithPath:myPathDocs];

    
    [self setupAndStartCaptureSession];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.overlayLabel.text = @"";
    self.overlaySwitch.on = [VWWUserDefaults overlayDataOnVideo];
    self.overlayLabel.hidden = ![VWWUserDefaults overlayDataOnVideo];
    
    self.dataLogController = [VWWDataLogController sharedInstance];
    self.dataLogController.delegate = self;
    [self.dataLogController start];
    
    
    

    [NSTimer scheduledTimerWithTimeInterval:0.25 block:^{
        [self.dataLogController calibrate];
    } repeats:NO];
}


- (void)viewDidUnload
{
	[super viewDidUnload];
    
    [self stopAndTearDownCaptureSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:VWWSegueRecordToEdit]){
        VWWEditVideoTableViewController *vc = segue.destinationViewController;
        vc.videoURL = sender;
    }
}


#pragma mark IBActions


- (IBAction)calibrateButtonTouchUpInside:(id)sender {
    [self.dataLogController calibrate];
}

- (IBAction)startButtonTouchUpInside:(id)sender {
	// Wait for the recording to start/stop before re-enabling the record button.
	[[self startButton] setEnabled:NO];
	
	if (recording) {
		// The recordingWill/DidStop delegate methods will fire asynchronously in response to this call
		[self stopRecording];
	}
	else {
		// The recordingWill/DidStart delegate methods will fire asynchronously in response to this call
        [self startRecording];
	}
}



- (IBAction)overlaySwitchValueChanged:(UISwitch*)sender {
    [VWWUserDefaults setOverlayDataOnVideo:sender.on];
    self.overlayLabel.hidden = !sender.on;
}

#pragma mark Private methods


#pragma mark VWWDataLogControllerDelegate
-(void)dataLogController:(VWWDataLogController*)sender didLogDataPoint:(NSDictionary*)dataPoint{
}

-(void)dataLogController:(VWWDataLogController *)sender didUpdateLogString:(NSString*)logString{
    self.overlayLabel.text = logString;
}


#pragma mark AVFoundation

#pragma mark Utilities

- (void) calculateFramerateAtTimestamp:(CMTime) timestamp
{
	[previousSecondTimestamps addObject:[NSValue valueWithCMTime:timestamp]];
    
	CMTime oneSecond = CMTimeMake( 1, 1 );
	CMTime oneSecondAgo = CMTimeSubtract( timestamp, oneSecond );
    
	while( CMTIME_COMPARE_INLINE( [[previousSecondTimestamps objectAtIndex:0] CMTimeValue], <, oneSecondAgo ) )
		[previousSecondTimestamps removeObjectAtIndex:0];
    
	Float64 newRate = (Float64) [previousSecondTimestamps count];
	videoFrameRate = (videoFrameRate + newRate) / 2;
}

- (void)removeFile:(NSURL *)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [fileURL path];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
		if (!success)
			[self showError:error];
    }
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGFloat angle = 0.0;
	
	switch (orientation) {
		case AVCaptureVideoOrientationPortrait:
			angle = 0.0;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			angle = M_PI;
			break;
		case AVCaptureVideoOrientationLandscapeRight:
			angle = -M_PI_2;
			break;
		case AVCaptureVideoOrientationLandscapeLeft:
			angle = M_PI_2;
			break;
		default:
			break;
	}
    
	return angle;
}

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	// Calculate offsets from an arbitrary reference orientation (portrait)
	CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
	CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:videoOrientation];
	
	// Find the difference in angle between the passed in orientation and the current video orientation
	CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
	transform = CGAffineTransformMakeRotation(angleOffset);
	
	return transform;
}

#pragma mark Recording

- (void)saveMovieToCameraRoll
{
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library writeVideoAtPathToSavedPhotosAlbum:movieURL
								completionBlock:^(NSURL *assetURL, NSError *error) {
									if (error)
										[self showError:error];
									else
										[self removeFile:movieURL];
									
									dispatch_async(movieWritingQueue, ^{
										recordingWillBeStopped = NO;
										recording = NO;

                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [[self startButton] setEnabled:YES];
                                            
                                            [UIApplication sharedApplication].idleTimerDisabled = NO;
                                            
                                            [self resumeCaptureSession];
                                        });
									});
								}];
}

- (void) writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType
{
	if ( assetWriter.status == AVAssetWriterStatusUnknown ) {
		
        if ([assetWriter startWriting]) {
			[assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
		}
		else {
			[self showError:[assetWriter error]];
		}
	}
	
	if ( assetWriter.status == AVAssetWriterStatusWriting ) {
		
		if (mediaType == AVMediaTypeVideo) {
			if (assetWriterVideoIn.readyForMoreMediaData) {
				if (![assetWriterVideoIn appendSampleBuffer:sampleBuffer]) {
					[self showError:[assetWriter error]];
				} else {
//                    VWW_LOG_DEBUG(@"Appended buffer");
                }
			}
		}
		else if (mediaType == AVMediaTypeAudio) {
			if (assetWriterAudioIn.readyForMoreMediaData) {
				if (![assetWriterAudioIn appendSampleBuffer:sampleBuffer]) {
					[self showError:[assetWriter error]];
				}
			}
		}
	}
}

- (BOOL) setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription
{
	const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    
	size_t aclSize = 0;
	const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
	NSData *currentChannelLayoutData = nil;
	
	// AVChannelLayoutKey must be specified, but if we don't know any better give an empty data and let AVAssetWriter decide.
	if ( currentChannelLayout && aclSize > 0 )
		currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
	else
		currentChannelLayoutData = [NSData data];
	
	NSDictionary *audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithInteger:kAudioFormatMPEG4AAC], AVFormatIDKey,
											  [NSNumber numberWithFloat:currentASBD->mSampleRate], AVSampleRateKey,
											  [NSNumber numberWithInt:64000], AVEncoderBitRatePerChannelKey,
											  [NSNumber numberWithInteger:currentASBD->mChannelsPerFrame], AVNumberOfChannelsKey,
											  currentChannelLayoutData, AVChannelLayoutKey,
											  nil];
	if ([assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
		assetWriterAudioIn = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
		assetWriterAudioIn.expectsMediaDataInRealTime = YES;
		if ([assetWriter canAddInput:assetWriterAudioIn])
			[assetWriter addInput:assetWriterAudioIn];
		else {
			NSLog(@"Couldn't add asset writer audio input.");
            return NO;
		}
	}
	else {
		NSLog(@"Couldn't apply audio output settings.");
        return NO;
	}
    
    return YES;
}

- (BOOL) setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription
{
	float bitsPerPixel;
	CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
	int numPixels = dimensions.width * dimensions.height;
	int bitsPerSecond;
	
	// Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
	if ( numPixels < (640 * 480) )
		bitsPerPixel = 4.05; // This bitrate matches the quality produced by AVCaptureSessionPresetMedium or Low.
	else
		bitsPerPixel = 11.4; // This bitrate matches the quality produced by AVCaptureSessionPresetHigh.
	
	bitsPerSecond = numPixels * bitsPerPixel;
	
	NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
											  AVVideoCodecH264, AVVideoCodecKey,
											  [NSNumber numberWithInteger:dimensions.width], AVVideoWidthKey,
											  [NSNumber numberWithInteger:dimensions.height], AVVideoHeightKey,
											  [NSDictionary dictionaryWithObjectsAndKeys:
											   [NSNumber numberWithInteger:bitsPerSecond], AVVideoAverageBitRateKey,
											   [NSNumber numberWithInteger:30], AVVideoMaxKeyFrameIntervalKey,
											   nil], AVVideoCompressionPropertiesKey,
											  nil];
	if ([assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
		assetWriterVideoIn = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
		assetWriterVideoIn.expectsMediaDataInRealTime = YES;
		assetWriterVideoIn.transform = [self transformFromCurrentVideoOrientationToOrientation:referenceOrientation];
		if ([assetWriter canAddInput:assetWriterVideoIn])
			[assetWriter addInput:assetWriterVideoIn];
		else {
			NSLog(@"Couldn't add asset writer video input.");
            return NO;
		}
	}
	else {
		NSLog(@"Couldn't apply video output settings.");
        return NO;
	}
    
    return YES;
}

- (void) startRecording
{
	dispatch_async(movieWritingQueue, ^{
        
		if ( recordingWillBeStarted || recording )
			return;
        
		recordingWillBeStarted = YES;
        
		// recordingDidStart is called from captureOutput:didOutputSampleBuffer:fromConnection: once the asset writer is setup
//		[self.delegate recordingWillStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self startButton] setEnabled:NO];
            [[self startButton] setTitle:@"Stop" forState:UIControlStateNormal ];
            
            // Disable the idle timer while we are recording
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        });
        
		// Remove the file if one with the same name already exists
		[self removeFile:movieURL];
        
		// Create an asset writer
		NSError *error;
		assetWriter = [[AVAssetWriter alloc] initWithURL:movieURL fileType:(NSString *)kUTTypeQuickTimeMovie error:&error];
		if (error)
			[self showError:error];
	});
}

- (void) stopRecording
{
	dispatch_async(movieWritingQueue, ^{
		
		if ( recordingWillBeStopped || (recording == NO) )
			return;
		
		recordingWillBeStopped = YES;
		
		// recordingDidStop is called from saveMovieToCameraRoll
//		[self.delegate recordingWillStop];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Disable until saving to the camera roll is complete
            [[self startButton] setTitle:@"Record" forState:UIControlStateNormal];
            [[self startButton] setEnabled:NO];
            
            // Pause the capture session so that saving will be as fast as possible.
            // We resume the sesssion in recordingDidStop:
            [self pauseCaptureSession];
        });
        
        //To determine whether the operation succeeded, your handler can check the value of AVAssetWriter.status.
        // If the status is AVAssetWriterStatusFailed, AVAsset.error will contain an instance of NSError that describes the failure.
        [assetWriter finishWritingWithCompletionHandler:^{
            
            if(assetWriter.status == AVAssetWriterStatusFailed){
                [self showError:[assetWriter error]];
            } else {
                [self saveMovieToCameraRoll];
            }
            
            assetWriter = nil;
			readyToRecordVideo = NO;
			readyToRecordAudio = NO;
        }];
	});
}

#pragma mark Processing


- (void)processPixelBuffer: (CVImageBufferRef)pixelBuffer
{
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
	
	int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
	int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
	unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
	for( int row = 0; row < bufferHeight; row++ ) {
		for( int column = 0; column < bufferWidth; column++ ) {
			pixel[1] = 0; // De-green (second pixel in BGRA is green)
			pixel += BYTES_PER_PIXEL;
		}
	}
	
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
}

#pragma mark Capture

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
	if ( connection == videoConnection ) {
		
		// Get framerate
		CMTime timestamp = CMSampleBufferGetPresentationTimeStamp( sampleBuffer );
		[self calculateFramerateAtTimestamp:timestamp];
        
		// Get frame dimensions (for onscreen display)
		if (videoDimensions.width == 0 && videoDimensions.height == 0)
			videoDimensions = CMVideoFormatDescriptionGetDimensions( formatDescription );
		
		// Get buffer type
		if ( videoType == 0 )
			videoType = CMFormatDescriptionGetMediaSubType( formatDescription );
        
		CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
		
		// Synchronously process the pixel buffer to de-green it.
		[self processPixelBuffer:pixelBuffer];
		
		// Enqueue it for preview.  This is a shallow queue, so if image processing is taking too long,
		// we'll drop this frame for preview (this keeps preview latency low).
		OSStatus err = CMBufferQueueEnqueue(previewBufferQueue, sampleBuffer);
		if ( !err ) {
			dispatch_async(dispatch_get_main_queue(), ^{
				CMSampleBufferRef sbuf = (CMSampleBufferRef)CMBufferQueueDequeueAndRetain(previewBufferQueue);
				if (sbuf) {
//					CVImageBufferRef pixBuf = CMSampleBufferGetImageBuffer(sbuf);
//					[self.delegate pixelBufferReadyForDisplay:pixBuf];
//					CFRelease(sbuf);
				}
			});
		}
	}
    
	CFRetain(sampleBuffer);
	CFRetain(formatDescription);
	dispatch_async(movieWritingQueue, ^{
        
		if ( assetWriter ) {
            
			BOOL wasReadyToRecord = (readyToRecordAudio && readyToRecordVideo);
			
			if (connection == videoConnection) {
				
				// Initialize the video input if this is not done yet
				if (!readyToRecordVideo)
					readyToRecordVideo = [self setupAssetWriterVideoInput:formatDescription];
				
				// Write video data to file
				if (readyToRecordVideo && readyToRecordAudio)
					[self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
			}
			else if (connection == audioConnection) {
				
				// Initialize the audio input if this is not done yet
				if (!readyToRecordAudio)
					readyToRecordAudio = [self setupAssetWriterAudioInput:formatDescription];
				
				// Write audio data to file
				if (readyToRecordAudio && readyToRecordVideo)
					[self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
			}
			
			BOOL isReadyToRecord = (readyToRecordAudio && readyToRecordVideo);
			if ( !wasReadyToRecord && isReadyToRecord ) {
				recordingWillBeStarted = NO;
				recording = YES;
//				[self.delegate recordingDidStart];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[self startButton] setEnabled:YES];
                });
			}
		}
		CFRelease(sampleBuffer);
		CFRelease(formatDescription);
	});
}

- (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if ([device position] == position)
            return device;
    
    return nil;
}

- (AVCaptureDevice *)audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0)
        return [devices objectAtIndex:0];
    
    return nil;
}

- (BOOL) setupCaptureSession
{
	/*
     Overview: RosyWriter uses separate GCD queues for audio and video capture.  If a single GCD queue
     is used to deliver both audio and video buffers, and our video processing consistently takes
     too long, the delivery queue can back up, resulting in audio being dropped.
     
     When recording, RosyWriter creates a third GCD queue for calls to AVAssetWriter.  This ensures
     that AVAssetWriter is not called to start or finish writing from multiple threads simultaneously.
     
     RosyWriter uses AVCaptureSession's default preset, AVCaptureSessionPresetHigh.
	 */
    
    /*
	 * Create capture session
	 */
    captureSession = [[AVCaptureSession alloc] init];
    
    /*
	 * Create audio connection
	 */
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    if ([captureSession canAddInput:audioIn])
        [captureSession addInput:audioIn];
	
	AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
	dispatch_queue_t audioCaptureQueue = dispatch_queue_create("com.vaporwarewolf.rcvideo.audiocapture", DISPATCH_QUEUE_SERIAL);
	[audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
	if ([captureSession canAddOutput:audioOut])
		[captureSession addOutput:audioOut];
	audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
	/*
	 * Create video connection
	 */
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self videoDeviceWithPosition:AVCaptureDevicePositionBack] error:nil];
    if ([captureSession canAddInput:videoIn])
        [captureSession addInput:videoIn];
    
    
    // ***** Outputs
    // Configure preview layer so the user can see
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    UIView *view = self.previewView;
    CALayer *viewLayer = [view layer];
    previewLayer.frame = view.bounds;
    [viewLayer addSublayer:previewLayer];
    
    
	AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
	/*
     RosyWriter prefers to discard late video frames early in the capture pipeline, since its
     processing can take longer than real-time on some platforms (such as iPhone 3GS).
     Clients whose image processing is faster than real-time should consider setting AVCaptureVideoDataOutput's
     alwaysDiscardsLateVideoFrames property to NO.
	 */
	[videoOut setAlwaysDiscardsLateVideoFrames:YES];
	[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
	dispatch_queue_t videoCaptureQueue = dispatch_queue_create("com.vaporwarewolf.rcvideo.videocapture", DISPATCH_QUEUE_SERIAL);
	[videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];

	if ([captureSession canAddOutput:videoOut])
		[captureSession addOutput:videoOut];
	videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
	videoOrientation = [videoConnection videoOrientation];
    
	return YES;
}

- (void) setupAndStartCaptureSession
{
	// Create a shallow queue for buffers going to the display for preview.
	OSStatus err = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &previewBufferQueue);
	if (err)
		[self showError:[NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]];
	
	// Create serial queue for movie writing
//	movieWritingQueue = dispatch_queue_create("com.vaporwarewolf.rcvideo.writing", DISPATCH_QUEUE_SERIAL);
    movieWritingQueue = dispatch_get_main_queue();
	
    if ( !captureSession )
		[self setupCaptureSession];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionStoppedRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:captureSession];
	
	if ( !captureSession.isRunning )
		[captureSession startRunning];
}

- (void) pauseCaptureSession
{
	if ( captureSession.isRunning )
		[captureSession stopRunning];
}

- (void) resumeCaptureSession
{
	if ( !captureSession.isRunning )
		[captureSession startRunning];
}

- (void)captureSessionStoppedRunningNotification:(NSNotification *)notification
{
	dispatch_async(movieWritingQueue, ^{
//		if ( [self isRecording] ) {
        if (recording) {
			[self stopRecording];
		}
	});
}

- (void) stopAndTearDownCaptureSession
{
    [captureSession stopRunning];
	if (captureSession)
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:captureSession];

	captureSession = nil;
	if (previewBufferQueue) {
		CFRelease(previewBufferQueue);
		previewBufferQueue = NULL;
	}
	if (movieWritingQueue) {
		movieWritingQueue = NULL;
	}
}

#pragma mark Error Handling

- (void)showError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}


@end
