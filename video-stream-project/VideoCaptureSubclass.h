//
//  VideoCaptureSubclass.h
//  video-stream-project
//
//  Created by JASON HARRIS on 11/11/15.
//  Copyright © 2015 Jason Harris. All rights reserved.
//

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
