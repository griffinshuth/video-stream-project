//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
import AVFoundation
import UIKit

class VideoCaptureSubclass: AVCaptureVideoDataOutput, AVCaptureMultipeerVideoDataOutputDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var outputVideoMultipeer: AVCaptureMultipeerVideoDataOutput?

    func captureSessionMethod() {
        //capture session
        captureSession = AVCaptureSession()

        //preview file
        var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
        if let captureSession = captureSession {
            captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        captureVideoPreviewLayer?.videoGravity = .resizeAspectFill
        captureVideoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: 640, height: 640)
        if let captureVideoPreviewLayer = captureVideoPreviewLayer {
            previewLayer?.addSublayer(captureVideoPreviewLayer)
        }

        //create video device input
        let videoDevice = AVCaptureDevice.default(for: .video)
        var videoInput: AVCaptureDeviceInput? = nil
        do {
            if let videoDevice = videoDevice {
                videoInput = try AVCaptureDeviceInput(device: videoDevice)
            }
        } catch {
        }
        if let videoInput = videoInput {
            captureSession?.addInput(videoInput)
        }

        //create output
        let multipeerVideoOutput = AVCaptureMultipeerVideoDataOutput(displayName: UIDevice.current.name)
        multipeerVideoOutput.delegate = self
        captureSession?.addOutput(multipeerVideoOutput)
        captureSession?.startRunning()



        //    self.outputVideoMultipeer = [[AVCaptureMultipeerVideoDataOutput alloc] initWithDisplayName:@"VideoStream"];
        //    self.outputVideoMultipeer.delegate = self;


    }

    func stopStreamingVideo() {

        captureSession?.stopRunning()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}