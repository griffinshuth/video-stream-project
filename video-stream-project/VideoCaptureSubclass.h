
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <AVCaptureMultipeerVideoDataOutput.h>

@interface VideoCaptureSubclass : AVCaptureVideoDataOutput <AVCaptureMultipeerVideoDataOutputDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMultipeerVideoDataOutput *outputVideoMultipeer;


-(void)captureSessionMethod;
-(void)stopStreamingVideo;


@end
