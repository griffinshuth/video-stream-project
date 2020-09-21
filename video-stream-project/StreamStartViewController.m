

#import "StreamStartViewController.h"

@interface StreamStartViewController ()
@property (nonatomic, strong) VideoCaptureSubclass *videoCaptureInstance;

@end

@implementation StreamStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startTheStream:(id)sender
{
    self.videoCaptureInstance = [[VideoCaptureSubclass alloc] init];
    [self.videoCaptureInstance captureSessionMethod];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
}
- (IBAction)stopStreamingPressed:(id)sender
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.videoCaptureInstance stopStreamingVideo];
}

-(BOOL)isBeingDismissed
{
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    return YES;
}

@end
