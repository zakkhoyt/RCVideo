
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>

@protocol RosyWriterVideoProcessorDelegate;

@interface RosyWriterVideoProcessor : NSObject <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> 
{  
    
	

}


@property (readwrite, assign) id <RosyWriterVideoProcessorDelegate> delegate;

@property (readonly) Float64 videoFrameRate;
@property (readonly) CMVideoDimensions videoDimensions;
@property (readonly) CMVideoCodecType videoType;

@property (readwrite) AVCaptureVideoOrientation referenceOrientation;

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation;

- (void) showError:(NSError*)error;

- (void) setupAndStartCaptureSession;
- (void) stopAndTearDownCaptureSession;

- (void) startRecording;
- (void) stopRecording;

- (void) pauseCaptureSession; // Pausing while a recording is in progress will cause the recording to be stopped and saved.
- (void) resumeCaptureSession;

@property(readonly, getter=isRecording) BOOL recording;

@end

@protocol RosyWriterVideoProcessorDelegate <NSObject>
@required
- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer;	// This method is always called on the main thread.
- (void)recordingWillStart;
- (void)recordingDidStart;
- (void)recordingWillStop;
- (void)recordingDidStop;
@end
