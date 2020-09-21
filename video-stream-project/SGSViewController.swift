//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  SGSViewController.swift
//  SGSMultipeerVideoMixer
//
//  Created by PJ Gray on 12/29/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

import AVFoundation
import MultipeerConnectivity
import UIKit

class VideoViewController: UIViewController, MCNearbyServiceBrowserDelegate, MCSessionDelegate, UICollectionViewDataSource, UICollectionViewDelegate, VideoPeerDelegate {
    private var myDevicePeerId: MCPeerID?
    private var session: MCSession?
    private var browser: MCNearbyServiceBrowser?
    private var peers: [AnyHashable : Any]?

    @IBOutlet private weak var collectionView: UICollectionView!
    private var cellCount = 0
}

class SGSViewController {
    func viewDidLoad() {
        super.viewDidLoad()

        peers = [:]

        cellCount = 0
        collectionView.reloadData()

        myDevicePeerId = MCPeerID(displayName: UIDevice.current.name)

        session = MCSession(peer: myDevicePeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self

        browser = MCNearbyServiceBrowser(peer: myDevicePeerId, serviceType: "multipeer-video")
        browser.delegate = self
        browser.startBrowsingForPeers()
    }

    func viewDidAppear(_ animated: Bool) {
        //    [self showAssistant];
    }

    func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - UICollectionView
    func collectionView(_ view: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? CollectionViewImageViewCell

        return cell!
    }

// MARK: - MCSessionDelegate Methods
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .connected:
                print(String(format: "CONNECTED \n peer id: %@, session peerID: %@, state %lu", peerID.displayName, session.myPeerID.displayName, state))
                DispatchQueue.main.async(execute: {
                    let indexPath = IndexPath(item: self.cellCount, section: 0)

                    let newVideoPeer = VideoPeer(peer: peerID, at: indexPath)
                    newVideoPeer.delegate = self

                    peers[peerID.displayName] = newVideoPeer

                    self.cellCount = self.cellCount + 1
                    self.collectionView.reloadData()
                })
            case .connecting:
                print(String(format: "CONNECTING \n peer id: %@, session peerID: %@, state %lu", peerID.displayName, session.myPeerID.displayName, state))
            case .notConnected:
                print(String(format: "NOT CONNECTED \n peer id: %@, session peerID: %@, state %lu", peerID.displayName, session.myPeerID.displayName, state))
                DispatchQueue.main.async(execute: {

                    var peer = peers[peerID.displayName]
                    peer?.stopPlaying()
                    peer = nil

                    peers.removeObject(forKey: peerID.displayName)

                    self.cellCount = self.cellCount - 1
                    self.collectionView.reloadData()
                })
            @unknown default:
                break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

        //    NSLog(@"(%@) Read %d bytes", peerID.displayName, data.length);
        let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnyHashable : Any]
        var image: UIImage? = nil
        if let aDict = dict?["image"] as? Data {
            image = UIImage(data: aDict, scale: 2.0)
        }
        let framesPerSecond = dict?["framesPerSecond"] as? NSNumber

        let thisVideoPeer = peers[peerID.displayName]
        thisVideoPeer?.addImageFrame(image, withFPS: framesPerSecond)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("did receive stream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }

// MARK: - MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        browser.startBrowsingForPeers()
        print("peer browser inviting \(peerID.displayName)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }

// MARK: - SGSVideoPeerDelegate
    func show(_ image: UIImage?, at indexPath: IndexPath?) {
        DispatchQueue.main.async(execute: {
            let cell = self.collectionView.cellForItem(at: indexPath) as? CollectionViewImageViewCell
            cell?.backgroundColor = UIColor.black
            //        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            //        [cell.imageView sizeToFit];
            //        NSString *imageSize = NSStringFromCGSize(cell.imageView.bounds.size);
            //        NSString *intrinsicImageSize = NSStringFromCGSize(cell.imageView.intrinsicContentSize);
            //        NSString *cellSize = NSStringFromCGSize(cell.bounds.size);
            //        NSLog(@".\n image size : %@, \n intrinsic image size : %@, \n cell size %@",imageSize,intrinsicImageSize,cellSize);
            //        cell.imageView.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
            //        cell.imageView.bounds = CGRectMake(0, 0, cell.bound   s.size.width, cell.bounds.size.height);
            cell?.imageView.image = image
            let i: Any? = nil
        })
    }

    func raiseFramerate(forPeer peerID: MCPeerID?) {
        print("(\(peerID?.displayName ?? "")) raise framerate")
        let data = "raiseFramerate".data(using: .utf8)
        do {
            if let data = data {
                try session.send(data, toPeers: [peerID].compactMap { $0 }, with: .unreliable)
            }
        } catch {
        }
    }

    func lowerFramerate(forPeer peerID: MCPeerID?) {
        print("(\(peerID?.displayName ?? "")) lower framerate")
        let data = "lowerFramerate".data(using: .utf8)
        do {
            if let data = data {
                try session.send(data, toPeers: [peerID].compactMap { $0 }, with: .unreliable)
            }
        } catch {
        }
    }
}