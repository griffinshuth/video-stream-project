

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol VideoPeerDelegate <NSObject>
- (void) showImage:(UIImage*) image atIndexPath:(NSIndexPath*) indexPath;
- (void) raiseFramerateForPeer:(MCPeerID*) peerID;
- (void) lowerFramerateForPeer:(MCPeerID*) peerID;
@end

@interface VideoPeer : NSObject

@property (strong, nonatomic) id delegate;
@property BOOL useAutoFramerate;

- (instancetype) initWithPeer:(MCPeerID*) peerID atIndexPath:(NSIndexPath*) indexPath;

- (void) addImageFrame:(UIImage*) image withFPS:(NSNumber*) fps;
- (void) stopPlaying;

@end
