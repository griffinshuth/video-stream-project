//
//  VideoCaptureSubclass.m
//  video-stream-project
//
//  Created by JASON HARRIS on 11/11/15.
//  Copyright © 2015 Jason Harris. All rights reserved.
//

#import "VideoCaptureSubclass.h"

@implementation VideoCaptureSubclass


-(void)captureSessionMethod
{
    //capture session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //preview file
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    captureVideoPreviewLayer.frame = CGRectMake(0, 0, 640, 640);
    [self.previewLayer addSublayer:captureVideoPreviewLayer];
    
    //create video device input
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    [self.captureSession addInput:videoInput];
    
    //create output
    AVCaptureMultipeerVideoDataOutput *multipeerVideoOutput = [[AVCaptureMultipeerVideoDataOutput alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    multipeerVideoOutput.delegate = self;
    [self.captureSession addOutput:multipeerVideoOutput];
    [self.captureSession startRunning]; 
    
    
    
//    self.outputVideoMultipeer = [[AVCaptureMultipeerVideoDataOutput alloc] initWithDisplayName:@"VideoStream"];
//    self.outputVideoMultipeer.delegate = self;
    
    
}


-(void)stopStreamingVideo
{

    [self.captureSession stopRunning];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}








@end
