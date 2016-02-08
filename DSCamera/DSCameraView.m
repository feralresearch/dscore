#import "DSCameraManager.h"


#define FREEWHEELING_PERIOD_IN_SECONDS 0.5
#define ADVANCE_INTERVAL_IN_SECONDS 0.1

@interface DSCameraView (){
    AVPlayerItem *_playerItem;
    AVPlayerItemVideoOutput *_playerItemVideoOutput;
    CVDisplayLinkRef _displayLink;
    CMVideoFormatDescriptionRef _videoInfo;

    uint64_t _lastHostTime;
    dispatch_queue_t _queue;
    DSCamera* _camera;
}
@end

@interface DSCameraView (AVPlayerItemOutputPullDelegate) <AVPlayerItemOutputPullDelegate>
@end


@implementation DSCameraView

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);


-(void)runTest{
    [_camera shutdown];
    [videoLayer flushAndRemoveImage];
    [videoLayer removeFromSuperlayer];
    [self.layer addSublayer:videoLayer];

    //[openCV testWithImageA:[NSImage imageNamed:@"a.png"] B:[NSImage imageNamed:@"b.png"]];
    CALayer* testLayer=[[CALayer alloc] init];
    [testLayer setContents:[NSImage imageNamed:@"a.png"]];
    [self.layer setContents:testLayer];
    
}

-(id)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];

    if (self){
        _videoInfo = nil;

        _queue = dispatch_queue_create(NULL, NULL);

        _playerItemVideoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:@{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB)}];
        if (_playerItemVideoOutput){
            // Create a CVDisplayLink to receive a callback at every vsync
            CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
            CVDisplayLinkSetOutputCallback(_displayLink, displayLinkCallback, (__bridge void *)self);
            // Pause the displayLink till ready to conserve power
            CVDisplayLinkStop(_displayLink);
            // Request notification for media change in advance to start up displayLink or any setup necessary
            [_playerItemVideoOutput setDelegate:self queue:_queue];
            [_playerItemVideoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ADVANCE_INTERVAL_IN_SECONDS];
        }

        [self setWantsLayer:YES];
        [self setLayerUsesCoreImageFilters:YES];
        [self.layer setBackgroundColor:[[NSColor blackColor] CGColor]];

        // Filters and buffer
        filterNoir = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
        filterBlur = [CIFilter filterWithName:@"CIGaussianBlur"
                                      keysAndValues: @"inputRadius",
                                                     [NSNumber numberWithFloat:10.0],
                                                nil];


        frameBuffer = CFArrayCreateMutable( NULL, 0, &kCFTypeArrayCallBacks );
        [self setBufferDelayInSeconds:0];

        [self setViewID:@"?"];

        borderIsOn=NO;

    }

    return self;
}




- (void)viewWillMoveToSuperview:(NSView *)newSuperview{
    if (!newSuperview) {

        if (_videoInfo) {
            CFRelease(_videoInfo);
        }

        if (_displayLink)
        {
            CVDisplayLinkStop(_displayLink);
            CVDisplayLinkRelease(_displayLink);
        }

        dispatch_sync(_queue, ^{
            [_playerItemVideoOutput setDelegate:nil queue:NULL];
        });

    }
}

- (void)dealloc{
    self.playerItem = nil;
    videoLayer = nil;
}


- (DSCamera *)camera{
    return _camera;
}

-(NSString*)cameraID{
    return _camera.device.uniqueID;
}

- (void)setCamera:(DSCamera *)camera{



     //OC: openCV shutdown];
    [self removeAllFilters];
    [self removeBorder];
    
    if (_camera != camera){
            [_camera shutdown];
            _camera = camera;
            [_camera setDelegate:self];

        if(!_camera){
            dispatch_async(dispatch_get_main_queue(), ^{
                [videoLayer flushAndRemoveImage];
            });

            [videoLayer flushAndRemoveImage];
            [videoLayer removeFromSuperlayer];
        }else{

            // video layer
            videoLayer = [[AVSampleBufferDisplayLayer alloc] init];
            [videoLayer setFrame:self.layer.frame];
            videoLayer.position = CGPointMake(CGRectGetMidX(videoLayer.bounds), CGRectGetMidY(videoLayer.bounds));
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            videoLayer.backgroundColor = CGColorGetConstantColor(kCGColorBlack);
            videoLayer.layoutManager  = [CAConstraintLayoutManager layoutManager];
            videoLayer.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
            videoLayer.contentsGravity = kCAGravityResizeAspect;

            /*
             // video layer2
             videoLayer2 = [[AVSampleBufferDisplayLayer alloc] init];
             videoLayer2.frame = self.bounds;
             videoLayer2.position = CGPointMake(CGRectGetMidX(videoLayer.bounds), CGRectGetMidY(videoLayer.bounds));
             videoLayer2.videoGravity = AVLayerVideoGravityResizeAspect;
             videoLayer2.backgroundColor = [[NSColor clearColor] CGColor];//CGColorGetConstantColor(kCGColorBlack);
             videoLayer2.opacity=0.5;
             videoLayer2.layoutManager  = [CAConstraintLayoutManager layoutManager];
             videoLayer2.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
             videoLayer2.contentsGravity = kCAGravityResizeAspect;

             //videoLayer2.position = NSZeroPoint; //CGPointMake(CGRectGetMidX(videoLayer.bounds), CGRectGetMidY(videoLayer.bounds));
             videoLayer2.videoGravity = AVLayerVideoGravityResizeAspect;
             */
            //[self.layer addSublayer:videoLayer];
            //[self.layer addSublayer:videoLayer2];



            [self.layer addSublayer:videoLayer];

            //OC: openCV=[[OpenCVProcess alloc] init];
             //OC: [openCV setGrayMode:NO];

            NSOpenGLPixelFormatAttribute attribs [] = {
                //NSOpenGLPFAFullScreen,
                //NSOpenGLPFAScreenMask,
                //            CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
                //NSOpenGLPFAWindow,
                NSOpenGLPFAAllRenderers,
                NSOpenGLPFAAccelerated,
                NSOpenGLPFANoRecovery,
                //NSOpenGLPFAMPSafe,
                NSOpenGLPFABackingStore,
                NSOpenGLPFADoubleBuffer,        // double buffered
                NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)32, // 32 bit color buffer
                NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16, // 32 bit depth buffer
                //              NSOpenGLPFAAlphaSize, (NSOpenGLPixelFormatAttribute)8,
                (NSOpenGLPixelFormatAttribute)nil
            };

            NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
            if (!pixelFormat){NSLog(@"No OpenGL pixel format");}

            // NSOpenGLView does not handle context sharing, so we draw to a custom NSView instead
            //OC: [openCV setOpenGLContext:[[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil]];

            frameBuffer = CFArrayCreateMutable( NULL, 0, &kCFTypeArrayCallBacks );
             //OC: [openCV setParentView:self];
            if(isDisplayingInfo){
                camInfoLayer=nil;
                [self displayCamInfo];
            }
        }
    }
}




// New frame incoming from camera
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{

    if(!thisAppDelegate || !oscManager){
        thisAppDelegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
         //OC: oscManager = [thisAppDelegate oscManager];
    }


    // If video layer is ready
    if (videoLayer.readyForMoreMediaData) {

         //OC:
        /*
        if(!openCV.isRunning){
            [videoLayer flushAndRemoveImage];
            return;
        }*/


        //Push the frame into our buffer stack
        CFArrayAppendValue(frameBuffer, sampleBuffer);

        // If we're still buffering, wait
        if(isBuffering){
            [self displayBufferingMessage];
            [videoLayer enqueueSampleBuffer:sampleBuffer];


        // Otherwise just start displaying by popping the stack
        }else{
            [videoLayer flush];
            if(CFArrayGetCount(frameBuffer) >= 1){

                [self clearBufferingMessage];
                CMSampleBufferRef thisFrame = (CMSampleBufferRef)CFArrayGetValueAtIndex(frameBuffer, 0);
                [videoLayer enqueueSampleBuffer:thisFrame];

                // OpenCVProcess
                //OC:  _hasMotion = [openCV processFrame:thisFrame];

                // Pop off stack
                @try {
                    CFArrayRemoveValueAtIndex(frameBuffer, 0);
                }
                @catch (NSException *exception) {
                      NSLog(@"WARNING: Empty buffer");
                }
            }else{
                NSLog(@"WARNING: Empty buffer");
            }
        }
    }else{
        NSLog(@"WARNING: Video layer not ready, dropping frame");
    }



    [self refreshCamInfo];

}

-(BOOL)debugMode{
    return debugMode;
}
-(void)setDebugMode:(BOOL)mode{
    debugMode = mode;
     //OC: [openCV setDebugMode:mode];
}

-(BOOL)displayInfo{
    return isDisplayingInfo;
}

-(void)setDisplayInfo:(BOOL)displayInfo{
    isDisplayingInfo=displayInfo;
    if(displayInfo){
        [self displayCamInfo];
    }else{
        [self hideCamInfo];
    }
}
-(void)setImageLayerContents:(NSImage*)image{
     dispatch_async(dispatch_get_main_queue(), ^{
         [imageLayer setContents:image];
          });
}
-(void)displayCamInfo{
    if(!camInfoLayer){
        dispatch_async(dispatch_get_main_queue(), ^{

            imageLayer = [[CALayer alloc] init];
            [imageLayer setFrame:self.layer.frame];
            imageLayer.layoutManager  = [CAConstraintLayoutManager layoutManager];
            imageLayer.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
            imageLayer.contentsGravity = kCAGravityResizeAspect;
            [imageLayer setOpacity:0.5];
            [self.layer addSublayer:imageLayer];

            camInfoLayer = [[CALayer alloc] init];
            [camInfoLayer setFrame:self.layer.frame];

            infoText = [[CATextLayer alloc] init];
            [infoText setFrame:camInfoLayer.frame];
            [infoText setFont:@"Helvetica-Bold"];
            infoText.shadowColor = [[NSColor blackColor] CGColor];
            infoText.shadowOffset = CGSizeMake(0.0, 0.0);
            infoText.shadowOpacity = 1.0;
            infoText.shadowRadius = 1.0;

            [infoText setFontSize:20];

            [infoText setAlignmentMode:kCAAlignmentCenter];
            [infoText setForegroundColor:[[NSColor whiteColor] CGColor]];
            camInfoLayer.layoutManager  = [CAConstraintLayoutManager layoutManager];
            camInfoLayer.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
            camInfoLayer.contentsGravity = kCAGravityResizeAspect;

            infoText.layoutManager  = [CAConstraintLayoutManager layoutManager];
            infoText.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
            infoText.contentsGravity = kCAGravityResizeAspect;
            [camInfoLayer addSublayer:infoText];
            [self.layer addSublayer:camInfoLayer];

        });
        
    }
}

-(void)hideCamInfo{
    if(camInfoLayer){
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageLayer removeFromSuperlayer];
            [camInfoLayer removeFromSuperlayer];
            camInfoLayer=nil;
        });
    }
}
-(void)refreshCamInfo{
 dispatch_async(dispatch_get_main_queue(), ^{

     NSString* displayInfo = [NSString stringWithFormat:@"\n%@",_camera?_camera.device.localizedName:@"-OFF-"];
    displayInfo = [NSString stringWithFormat:@"%@\n Filter: %@",displayInfo,filter_noir?@"YES":@"NO"];
     displayInfo = [NSString stringWithFormat:@"%@\n Motion: %@",displayInfo,_hasMotion?@"YES":@"NO"];

     if(_hasMotion){
         [self drawBorder];
          //OC:
         /*
         [oscManager sendViaOSCAddress:[NSString stringWithFormat:@"%@/motion",_viewID]
                                  f_val:openCV.amountOfMotion];
         */
     }else{
         [self removeBorder];
     }

     if(bufferSizeInSeconds > 0){
         displayInfo = [NSString stringWithFormat:@"%@\n Buffer: %d",displayInfo,bufferSizeInSeconds];
     }
    [infoText setString:displayInfo];
     
});

}



-(void)clearBufferingMessage{
    if(uILayer){
        dispatch_async(dispatch_get_main_queue(), ^{
            [uILayer removeFromSuperlayer];
            uILayer=nil;
        });
    }
}

-(void)displayBufferingMessage{
    if(!uILayer){
        dispatch_async(dispatch_get_main_queue(), ^{
            uILayer = [[CALayer alloc] init];
            //[uILayer setContents:[NSImage imageNamed:NSImageNameBonjour]];
            [uILayer setFrame:self.layer.frame];

            CATextLayer *label = [[CATextLayer alloc] init];
            [label setFrame:uILayer.frame];
            [label setFont:@"Helvetica-Bold"];
            [label setFontSize:20];
            [label setString:@"\n\n\n\n\n\nBuffering..."];
            [label setAlignmentMode:kCAAlignmentCenter];
            [label setForegroundColor:[[NSColor greenColor] CGColor]];
            uILayer.layoutManager  = [CAConstraintLayoutManager layoutManager];
            uILayer.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
            uILayer.contentsGravity = kCAGravityResizeAspect;

            label.layoutManager  = [CAConstraintLayoutManager layoutManager];
            label.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
            label.contentsGravity = kCAGravityResizeAspect;
            [uILayer addSublayer:label];


            [self.layer addSublayer:uILayer];
        });

    }
}

- (AVPlayerItem *)playerItem{
    return _playerItem;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem{
    if (_playerItem != playerItem){
        if (_playerItem)
            [_playerItem removeOutput:_playerItemVideoOutput];

        _playerItem = playerItem;

        if (_playerItem)
            [_playerItem addOutput:_playerItemVideoOutput];
    }
}







static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext){

    /*
     DSCameraView *self = (__bridge DSCameraView *)displayLinkContext;
     AVPlayerItemVideoOutput *playerItemVideoOutput = self->_playerItemVideoOutput;

     // The displayLink calls back at every vsync (screen refresh)
     // Compute itemTime for the next vsync
     CMTime outputItemTime = [playerItemVideoOutput itemTimeForCVTimeStamp:*inOutputTime];
     if ([playerItemVideoOutput hasNewPixelBufferForItemTime:outputItemTime])
     {
     self->_lastHostTime = inOutputTime->hostTime;

     // Copy the pixel buffer to be displayed next and add it to AVSampleBufferDisplayLayer for display
     CVPixelBufferRef pixBuff = [playerItemVideoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];

     [self displayPixelBuffer:pixBuff atTime:outputItemTime];

     CVBufferRelease(pixBuff);
     }
     else
     {
     CMTime elapsedTime = CMClockMakeHostTimeFromSystemUnits(inNow->hostTime - self->_lastHostTime);
     if (CMTimeGetSeconds(elapsedTime) > FREEWHEELING_PERIOD_IN_SECONDS)
     {
     // No new images for a while.  Shut down the display link to conserve power, but request a wakeup call if new images are coming.

     CVDisplayLinkStop(displayLink);

     [playerItemVideoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ADVANCE_INTERVAL_IN_SECONDS];
     }
     }
     */

    return kCVReturnSuccess;
}



-(NSMenu*)menuForEvent:(NSEvent *)event{
    if(!thisAppDelegate){
        thisAppDelegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    }


    //DSCamera Menu
    NSMenuItem* camera = [[NSMenuItem alloc] initWithTitle:@"Camera" action:nil keyEquivalent:@""];
    NSMenu *cameraMenu = [[NSMenu alloc] initWithTitle:@"CameraMenu"];
    NSMenuItem* item = [cameraMenu addItemWithTitle:@"Off"
                          action:@selector(selectCamera:)
                   keyEquivalent:@""];
    [item setRepresentedObject:nil];
    
    
    for(NSString* cameraID in  [[DSCameraManager sharedDSCameraManager] availableDeviceByID]){
        AVCaptureDevice *device = [[[DSCameraManager sharedDSCameraManager] availableDeviceByID] objectForKey:cameraID];
         item = [cameraMenu addItemWithTitle:device.localizedName
                                                 action:@selector(selectCamera:)
                                          keyEquivalent:@""];
        [item setRepresentedObject:cameraID];
    }
    [camera setSubmenu:cameraMenu];



    // Effects Menu
    NSMenuItem* effects = [[NSMenuItem alloc] initWithTitle:@"Filters" action:nil keyEquivalent:@""];
    NSMenu *effectsMenu = [[NSMenu alloc] initWithTitle:@"EffectsMenu"];
    [effectsMenu addItemWithTitle:@"Remove All"
                           action:@selector(removeAllFilters)
                    keyEquivalent:@""];

    [effectsMenu addItemWithTitle:(filter_noir?@"Remove B+W":@"Add B+W")
                           action:@selector(toggle_noir)
                    keyEquivalent:@""];
    [effectsMenu addItemWithTitle:(filter_blur?@"Remove Blur":@"Add Blur")
                           action:@selector(toggle_blur)
                    keyEquivalent:@""];
    [effects setSubmenu:effectsMenu];

    // Buffer Menu
    NSMenuItem* buffer = [[NSMenuItem alloc] initWithTitle:@"Delay" action:nil keyEquivalent:@""];
    NSMenu *bufferMenu = [[NSMenu alloc] initWithTitle:@"BufferMenu"];
    [bufferMenu addItemWithTitle:@"Off"
                          action:@selector(setBufferDelayMenuHandler:)
                   keyEquivalent:@""];
    [bufferMenu addItemWithTitle:@"1 second"
                          action:@selector(setBufferDelayMenuHandler:)
                   keyEquivalent:@""];
    [bufferMenu addItemWithTitle:@"2.5 second"
                          action:@selector(setBufferDelayMenuHandler:)
                   keyEquivalent:@""];
    [bufferMenu addItemWithTitle:@"5 second"
                          action:@selector(setBufferDelayMenuHandler:)
                   keyEquivalent:@""];
    [bufferMenu addItemWithTitle:@"10 second"
                          action:@selector(setBufferDelayMenuHandler:)
                   keyEquivalent:@""];
    [bufferMenu addItemWithTitle:@"20 second"
                          action:@selector(setBufferDelayMenuHandler:)
                   keyEquivalent:@""];
    [bufferMenu addItemWithTitle:@"30 second"
                          action:@selector(setBufferDelayMenuHandler:)
                   keyEquivalent:@""];
    [bufferMenu addItemWithTitle:@"45 second"
                          action:@selector(setBufferDelayMenuHandler:)
                   keyEquivalent:@""];
    [bufferMenu addItemWithTitle:@"60 second"
                          action:@selector(setBufferDelayMenuHandler:)
                   keyEquivalent:@""];
    [buffer setSubmenu:bufferMenu];

    // Build menu
    NSMenu *contextMenu = [[NSMenu alloc] initWithTitle:@"ContextMenu"];
    [contextMenu addItem:camera];
    [contextMenu addItem:effects];
    [contextMenu addItem:buffer];



    // Show the menu
    [NSMenu popUpContextMenu:contextMenu withEvent:event forView:self];
    return nil;

}
-(void)setBufferDelayMenuHandler:(NSMenuItem*)menuItem{
    int delaytime =  (int)[menuItem.title integerValue];
    [self setBufferDelayInSeconds:delaytime];
}
-(void)setBufferDelayInSeconds:(int)seconds{

    // Setup buffer
    [bufferTimer invalidate];
    isBuffering=NO;

    CFArrayRemoveAllValues(frameBuffer);
    bufferSizeInSeconds=seconds;
    if(seconds > 0){
        isBuffering=YES;
        bufferTimer = [NSTimer scheduledTimerWithTimeInterval:(seconds)
                                                       target:self
                                                     selector:@selector(stopBuffering)
                                                     userInfo:nil
                                                      repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:bufferTimer forMode:NSDefaultRunLoopMode];
    }
    
    
}
-(void)stopBuffering{
    isBuffering=NO;
}


-(NSMutableArray*)removeFilter:(CIFilter*)filter from:(CALayer*)layer{
    NSMutableArray* withFilterRemoved = [NSMutableArray arrayWithArray:[layer filters]];
    [withFilterRemoved removeObject:filter];
    return withFilterRemoved;
}
-(NSMutableArray*)addFilter:(CIFilter*)filter to:(CALayer*)layer{
    NSMutableArray* withFilterAdded = [NSMutableArray arrayWithArray:[layer filters]];
        [withFilterAdded addObject:filter];
    return withFilterAdded;
}


-(void)removeAllFilters{
    [self setHasFilter_blur:NO];
    [self setHasFilter_noir:NO];
}

-(BOOL)hasFilter_noir{
    return filter_noir;
}
-(void)setHasFilter_noir:(BOOL)val{
    [videoLayer setFilters:[self removeFilter:filterNoir from:videoLayer]];
    filter_noir=NO;
     //OC: [openCV setGrayMode:NO];

    if(val && _camera.device){
        [videoLayer setFilters:[self addFilter:filterNoir to:videoLayer]];
        filter_noir=YES;
        //OC:  [openCV setGrayMode:YES];
    }

}
-(void)toggle_noir{
    if(filter_noir){
        [self setHasFilter_noir:NO];
        
    }else{
        [self setHasFilter_noir:YES];
       
    }
}

-(BOOL)hasFilter_blur{
    return filter_blur;
}
-(void)setHasFilter_blur:(BOOL)val{
    if(!videoLayer){
        NSLog(@"WARNING: videolayer not defined");
        return;
    }
    [videoLayer setFilters:[self removeFilter:filterBlur from:videoLayer]];
    filter_blur=NO;

    if(val && _camera.device){
        [videoLayer setFilters:[self addFilter:filterBlur to:videoLayer]];
        filter_blur=YES;
    }
}
-(void)toggle_blur{
    if(filter_blur){
        [self setHasFilter_blur:NO];
    }else{
        [self setHasFilter_blur:YES];
    }
}

-(void)selectCamera:(NSMenuItem*)menuItem{

    if(menuItem.representedObject){
       DSCamera *newCam =[[DSCamera alloc] initWithCameraID:menuItem.representedObject delegate:self];
        [self setCamera:newCam];
    }else{
        [self setCamera:nil];
    }
}

-(void)removeBorder{

    if(borderIsOn){
        self.layer.masksToBounds   = YES;
        self.layer.borderWidth      = 0.0f ;


        [self.layer setBorderColor:[[NSColor blackColor] CGColor]];

        //OC:
        /*[oscManager sendViaOSCAddress:[NSString stringWithFormat:@"%@/motion",_viewID]
                                value:@"0"
                                 type:@"b"];
         */
        borderIsOn=NO;

    }

}


-(void)drawBorder{
    if(!borderIsOn){
        self.layer.masksToBounds   = YES;
        self.layer.borderWidth      = 6.0f ;


        [self.layer setBorderColor:[[NSColor greenColor] CGColor]];
        //OC:
        /*[oscManager sendViaOSCAddress:[NSString stringWithFormat:@"%@/motion",_viewID]
        value:@"1"
        type:@"b"];
        borderIsOn=YES;
         */
    }
}

@end

@implementation DSCameraView (AVPlayerItemOutputPullDelegate)

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender{
    // Start running again.
    _lastHostTime = CVGetCurrentHostTime();
    CVDisplayLinkStart(_displayLink);
}

@end
