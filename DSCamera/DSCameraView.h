#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
@class DSCamera;
@class OpenCVProcess;
@class DSOSCMgr;
@class AppDelegate;

@interface DSCameraView : NSView{
    CIFilter *filterNoir;
    CIFilter *filterBlur;

    BOOL isBuffering;
    int bufferSizeInSeconds;
    BOOL isDisplayingInfo;

    CFMutableArrayRef frameBuffer;
    CALayer *contentLayer;
    CALayer *uILayer;
    CALayer *camInfoLayer;
    CALayer *imageLayer;

    AVSampleBufferDisplayLayer *videoLayer;
    AVSampleBufferDisplayLayer *videoLayer2;
    AVSampleBufferDisplayLayer *videoLayer3;
    NSTimer* bufferTimer;
    CATextLayer *infoText;
    OpenCVProcess* openCV;

    BOOL debugMode;

    BOOL filter_noir;
    BOOL filter_blur;

    AppDelegate* thisAppDelegate;
    DSOSCMgr* oscManager;

    BOOL borderIsOn;
}

-(BOOL)debugMode;
-(void)setDebugMode:(BOOL)mode;
-(void)setImageLayerContents:(NSImage*)image;

-(BOOL)hasFilter_noir;
-(BOOL)hasFilter_blur;
-(void)setHasFilter_noir:(BOOL)val;
-(void)setHasFilter_blur:(BOOL)val;

@property BOOL displayInfo;


@property NSString* viewID;
@property BOOL hasMotion;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (readonly) NSString *cameraID;

@property (nonatomic, strong)DSCamera* camera;
-(void)runTest;
@end
