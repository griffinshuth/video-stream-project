//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  SGSVideoPeer.swift
//  SGSMultipeerVideoMixer
//
//  Created by PJ Gray on 1/1/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol VideoPeerDelegate: NSObjectProtocol {
    func show(_ image: UIImage?, at indexPath: IndexPath?)
    func raiseFramerate(forPeer peerID: MCPeerID?)
    func lowerFramerate(forPeer peerID: MCPeerID?)
}

class VideoPeer: NSObject {
    private var peerID: MCPeerID?
    private var isPlaying = false
    private var frames: [AnyHashable]?
    private var playerClock: Timer?
    private var indexPath: IndexPath?
    private var fps: NSNumber?
    private var numberOfFramesAtLastTick = 0
    private var numberOfTicksWithFullBuffer = 0

    var delegate: Any?
    var useAutoFramerate = false

    init(peer peerID: MCPeerID?, at indexPath: IndexPath?) {
        super.init()
        frames = []
        isPlaying = false
        self.peerID = peerID
        self.indexPath = indexPath
        numberOfTicksWithFullBuffer = 0
    }

    func addImageFrame(_ image: UIImage?, withFPS fps: NSNumber?) {
        self.fps = fps
        if playerClock == nil || (Float(playerClock?.timeInterval ?? 0.0) != (1.0 / fps?.floatValue ?? 0.0)) {
            print("(\(peerID?.displayName ?? "")) changing framerate: \(fps?.floatValue ?? 0.0)")

            DispatchQueue.main.async(execute: {
                if self.playerClock != nil {
                    self.playerClock?.invalidate()
                }

                let timeInterval = TimeInterval(1.0 / fps?.floatValue ?? 0.0)
                self.playerClock = Timer.scheduledTimer(
                    timeInterval: timeInterval,
                    target: self,
                    selector: #selector(playerClockTick),
                    userInfo: nil,
                    repeats: true)
            })
        }
        if let image = image {
            frames?.append(image)
        }
    }

    func stopPlaying() {
        if playerClock != nil {
            playerClock?.invalidate()
        }
    }

    // If using auto-framerate (self.useAutoFramerate == YES)
    // AUTO LOWER FRAMERATE BASED ON CONNECTION SPEED TO MATCH SENDER
    // Every clock tick, if playing: if the number of buffered frames goes down
    //      then send a msg saying to lower the framerate
    // else every 5th clocktick if it has stayed the same
    //      then send a msg saying to raise the framerate
    @objc func playerClockTick() {

        let delta = (frames?.count ?? 0) - numberOfFramesAtLastTick
        print(String(format: "(%@) fps: %1.1f frames total: %li  frames@last: %li delta: %li", peerID?.displayName ?? "", fps?.floatValue ?? 0.0, frames?.count ?? 0, numberOfFramesAtLastTick, delta))
        numberOfFramesAtLastTick = frames?.count ?? 0
        if isPlaying {

            if (frames?.count ?? 0) > 1 {


                if useAutoFramerate {
                    if (frames?.count ?? 0) >= 10 {
                        if numberOfTicksWithFullBuffer >= 30 {
                            // higher framerate
                            if let delegate = delegate {
                                delegate.raiseFramerate(forPeer: peerID)
                            }
                            numberOfTicksWithFullBuffer = 0
                        }

                        numberOfTicksWithFullBuffer += 1
                    } else {
                        numberOfTicksWithFullBuffer = 0
                        if delta <= -1 {
                            // lower framerate
                            if delegate != nil && fps?.floatValue ?? 0.0 > 5 {
                                delegate?.lowerFramerate(forPeer: peerID)
                            }
                        }
                    }
                }

                if let delegate = delegate {
                    delegate.show(frames?[0] as? UIImage, at: indexPath)
                }
                frames?.remove(at: 0)
            } else {
                isPlaying = false
            }
        } else {
            if (frames?.count ?? 0) > 10 {
                isPlaying = true
            }
        }
    }
}