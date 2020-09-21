//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
import AVCaptureMultipeerVideoDataOutput
import UIKit

class StreamStartViewController: UIViewController {
    private var videoCaptureInstance: VideoCaptureSubclass?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startTheStream(_ sender: Any) {
        videoCaptureInstance = VideoCaptureSubclass()
        videoCaptureInstance?.captureSessionMethod()
        UIApplication.shared.isIdleTimerDisabled = true

    }

    @IBAction func stopStreamingPressed(_ sender: Any) {
        UIApplication.shared.isIdleTimerDisabled = false
        videoCaptureInstance?.stopStreamingVideo()
    }

    override var isBeingDismissed: Bool {

        UIApplication.shared.isIdleTimerDisabled = false
        return true
    }
}