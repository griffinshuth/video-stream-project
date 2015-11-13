//
//  SGSViewController.m
//  SGSMultipeerVideoMixer
//
//  Created by PJ Gray on 12/29/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "VideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CollectionViewImageViewCell.h"
#import "VideoPeer.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface VideoViewController () <MCNearbyServiceBrowserDelegate, MCSessionDelegate, UICollectionViewDataSource, UICollectionViewDelegate, VideoPeerDelegate> {
    MCPeerID *_myDevicePeerId;
    MCSession *_session;
    MCNearbyServiceBrowser *_browser;
    NSMutableDictionary* _peers;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger cellCount;
@property (nonatomic, assign) bool allowSendingInvite;
@property (nonatomic, strong) NSMutableSet *peersWithInvitesSent;

@end

@implementation VideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allowSendingInvite = YES;
    self.peersWithInvitesSent = [[NSMutableArray alloc] init];
    _peers = @{}.mutableCopy;
    
    self.cellCount = 0;
    [self.collectionView reloadData];
    
    _myDevicePeerId = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    
    _session = [[MCSession alloc] initWithPeer:_myDevicePeerId securityIdentity:nil encryptionPreference:MCEncryptionNone];
    _session.delegate = self;
    
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_myDevicePeerId serviceType:@"multipeer-video"];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
}

- (void)viewDidAppear:(BOOL)animated {
//    [self showAssistant];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.cellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    CollectionViewImageViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ImageViewCell" forIndexPath:indexPath];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat width = MIN(screenSize.width, screenSize.height);
    
    return CGSizeMake(width, width);
}


#pragma mark - MCSessionDelegate Methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
		case MCSessionStateConnected: {
            NSLog(@"CONNECTED \n peer id: %@, session peerID: %@, state %lu",peerID.displayName,session.myPeerID.displayName,state);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:self.cellCount inSection:0];

                VideoPeer* newVideoPeer = [[VideoPeer alloc] initWithPeer:peerID atIndexPath:indexPath];
                newVideoPeer.delegate = self;
                
                _peers[peerID.displayName] = newVideoPeer;
                
                self.cellCount = self.cellCount + 1;
                [self.collectionView reloadData];
            });
            
			break;
        }
		case MCSessionStateConnecting:
            NSLog(@"CONNECTING \n peer id: %@, session peerID: %@, state %lu",peerID.displayName,session.myPeerID.displayName,state);
			break;
		case MCSessionStateNotConnected: {
            NSLog(@"NOT CONNECTED \n peer id: %@, session peerID: %@, state %lu",peerID.displayName,session.myPeerID.displayName,state);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                VideoPeer* peer = _peers[peerID.displayName];
                [peer stopPlaying];
                peer = nil;
                
                [_peers removeObjectForKey:peerID.displayName];
                
                self.cellCount = self.cellCount - 1;
                [self.collectionView reloadData];
            });
			break;
        }
	}
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
//    NSLog(@"(%@) Read %d bytes", peerID.displayName, data.length);
    NSDictionary* dict = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    UIImage* image = [UIImage imageWithData:dict[@"image"] scale:2.0];
    NSNumber* framesPerSecond = dict[@"framesPerSecond"];
    
    VideoPeer* thisVideoPeer = _peers[peerID.displayName];
    [thisVideoPeer addImageFrame:image withFPS:framesPerSecond];
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    NSLog(@"did receive stream");
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
}

#pragma mark - MCNearbyServiceBrowserDelegate

- (void) browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    
}

- (void) browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    bool alreadySentThisGuyOne = [self.peersWithInvitesSent containsObject:peerID.displayName];
    if (self.allowSendingInvite || !alreadySentThisGuyOne) //will send invite if peer is new or waited x seconds below
    {
        [browser invitePeer:peerID toSession:_session withContext:nil timeout:0];
        [self.peersWithInvitesSent addObject:peerID.displayName];
        self.allowSendingInvite = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.allowSendingInvite = YES;
        });
    }
//    [browser startBrowsingForPeers];
    NSLog(@"peer browser inviting %@",peerID.displayName);
}

- (void) browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    
}

#pragma mark - SGSVideoPeerDelegate

- (void) showImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        CollectionViewImageViewCell* cell = (CollectionViewImageViewCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor blackColor];
//        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        [cell.imageView sizeToFit];
//        NSString *imageSize = NSStringFromCGSize(cell.imageView.bounds.size);
//        NSString *intrinsicImageSize = NSStringFromCGSize(cell.imageView.intrinsicContentSize);
//        NSString *cellSize = NSStringFromCGSize(cell.bounds.size);
//        NSLog(@".\n image size : %@, \n intrinsic image size : %@, \n cell size %@",imageSize,intrinsicImageSize,cellSize);
//        cell.imageView.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
//        cell.imageView.bounds = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
        cell.imageView.image = image;
        id i;
    });
}

- (void) raiseFramerateForPeer:(MCPeerID *)peerID {
    NSLog(@"(%@) raise framerate", peerID.displayName);
    NSData* data = [@"raiseFramerate" dataUsingEncoding:NSUTF8StringEncoding];
    [_session sendData:data toPeers:@[peerID] withMode:MCSessionSendDataUnreliable error:nil];
}

- (void) lowerFramerateForPeer:(MCPeerID *)peerID {
    NSLog(@"(%@) lower framerate", peerID.displayName);
    NSData* data = [@"lowerFramerate" dataUsingEncoding:NSUTF8StringEncoding];
    [_session sendData:data toPeers:@[peerID] withMode:MCSessionSendDataUnreliable error:nil];
}

@end
