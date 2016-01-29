//
//  DSLayerView.m
//  DSCore
//
//  Created by Andrew on 12/30/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "DSLayerView.h"
#import "DSLayer.h"
#import "DSLayerSource.h"
#import "DSLayerSourceSyphon.h"
#import "DSSyphonSource.h"
#import "DSLayerSourceImage.h"
#import "DSLayerSourceCamera.h"
#import "DSLayerSourceVideo.h"
#import "DSSyphonDisplayLayer.h"

#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>
#import <Opengl/glext.h>
#import <Syphon/Syphon.h>
#import "NSImage+util.h"
#import "NSView+util.h"

@implementation DSLayerView

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(void)awakeFromNib{
    
    
    [self setWantsLayer:YES];
    //[self setLayer:[CALayer layer]];
    [self setLayerUsesCoreImageFilters:YES];
    
    baseLayer = [[CALayer alloc] init];
    [self.layer setBackgroundColor:[[NSColor blackColor] CGColor]];
    [baseLayer setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
    
    //NSLog(@"BLP: %f,%f",baseLayer.position.x,baseLayer.position.y);
    //centeredPosition=baseLayer.position;
    
    [self.layer addSublayer:baseLayer];
    
    [self setShiftX:0];
    [self setShiftY:0];
    [self setScaleZ:1];
    
    [self rebuildLayers];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowResized:) name:NSWindowDidResizeNotification
                                               object:[self window]];
    
    [self.layer setAnchorPoint:NSMakePoint(.5,.5 )];
    [self cancelOperation:self];
}

-(NSMutableArray*)filterArray{
    if(!filterArray){
        filterArray=[[NSMutableArray alloc] init];
    }
    return filterArray;
}
-(void)setFilterArray:(NSMutableArray *)newFilterArray{
    [self willChangeValueForKey:@"filterArray"];
        [baseLayer setFilters:newFilterArray];
    [self didChangeValueForKey:@"filterArray"];
}
-(void)removeAllFilters{
    [self setFilterArray:[[NSMutableArray alloc] init]];
}

-(void)addFilter:(CIFilter*)filter{
    NSMutableArray* newFilterArray = self.filterArray;
    [filterArray addObject:filter];
    [self setFilterArray:newFilterArray];
}
-(void)removeFilter:(CIFilter*)filter{
    NSMutableArray* newFilterArray = self.filterArray;
    [filterArray removeObject:filter];
    [self setFilterArray:newFilterArray];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)windowResized:(NSNotification *)notification;{
    //NSSize size = [[self window] frame].size;
    // [baseLayer setFrame:NSMakeRect(0, 0, size.width,size.height)];
    //NSLog(@"window width = %f, window height = %f", size.width,size.height);
    
    //NSLog(@"BLP: %f,%f",baseLayer.position.x,baseLayer.position.y);
    //centeredPosition=baseLayer.position;

    //[self rebuildLayers];
    
    /*
    // size the scrollView to fill the window, but keep its bounds constant
    NSRect rect = [[self.window contentView] frame];
    NSRect oldBounds = [self bounds];
    [self setFrame:rect];
    [self setBounds:oldBounds];
     */
}

-(void)moveLayer:(DSLayer*)layer toPosition:(int)position{
    [_layers removeObject:layer];
    [_layers insertObject:layer atIndex:position];
    [self rebuildLayers];
    
}

-(void)rebuildLayers{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    
    [baseLayer setSublayers:nil];
    baseLayer.layoutManager  = [CAConstraintLayoutManager layoutManager];
    baseLayer.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
    baseLayer.contentsGravity = kCAGravityResizeAspect;
    
    [self setShiftX:0];
    [self setShiftY:0];
    [self setScaleZ:1];
    for (DSLayer* layer in _layers){
        if(layer.source){
            // Syphon
            if([layer.source isKindOfClass:[DSLayerSourceSyphon class]]){
                
                layer.caLayer=[[DSSyphonDisplayLayer alloc] initWithSource:(DSLayerSourceSyphon*)layer.source];
                [[layer caLayer] setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
                [layer.caLayer setOpacity:layer.alpha];
                layer.caLayer.layoutManager  = [CAConstraintLayoutManager layoutManager];
                layer.caLayer.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
                layer.caLayer.contentsGravity = kCAGravityResize;
                [baseLayer addSublayer:layer.caLayer];
     
                
            // Image
            } else if([layer.source isKindOfClass:[DSLayerSourceImage class]]){
                
                DSLayerSourceImage* imgSourcedLayer = (DSLayerSourceImage*)layer.source;
                layer.caLayer=[[CALayer alloc] init];
                [[layer caLayer] setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
                [layer.caLayer setContents:imgSourcedLayer.image];
                [layer.caLayer setOpacity:layer.alpha];

                layer.caLayer.layoutManager  = [CAConstraintLayoutManager layoutManager];
                layer.caLayer.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
                layer.caLayer.contentsGravity = kCAGravityResize;
                
                [baseLayer addSublayer:layer.caLayer];
                
                
            // Video
            } else if([layer.source isKindOfClass:[DSLayerSourceVideo class]]){
                DSLayerSourceVideo* videoSourcedLayer = (DSLayerSourceVideo*)layer.source;
                layer.caLayer=[[AVPlayerLayer alloc] init];
                [[layer caLayer] setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
                [(AVPlayerLayer*)layer.caLayer setPlayer:videoSourcedLayer.player];
                [layer.caLayer setOpacity:layer.alpha];
                
                layer.caLayer.layoutManager  = [CAConstraintLayoutManager layoutManager];
                layer.caLayer.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
                layer.caLayer.contentsGravity = kCAGravityResize;

                [baseLayer addSublayer:layer.caLayer];


            // Camera
            } else if([layer.source isKindOfClass:[DSLayerSourceCamera class]]){
                DSLayerSourceCamera* camSourcedLayer = (DSLayerSourceCamera*)layer.source;
               
                [camSourcedLayer.previewLayer setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
                [camSourcedLayer.previewLayer setOpacity:layer.alpha];
                //camSourcedLayer.previewLayer.position = CGPointMake(CGRectGetMidX(layer.caLayer.bounds), CGRectGetMidY(camSourcedLayer.previewLayer.bounds));
                //((AVSampleBufferDisplayLayer*)layer.caLayer).videoGravity = AVLayerVideoGravityResizeAspect;
                //camSourcedLayer.previewLayer.backgroundColor = CGColorGetConstantColor(kCGColorBlack);
                //camSourcedLayer.previewLayer.layoutManager  = [CAConstraintLayoutManager layoutManager];
                camSourcedLayer.previewLayer.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
                camSourcedLayer.previewLayer.contentsGravity = kCAGravityResizeAspect;
                
                 layer.caLayer = camSourcedLayer.previewLayer;
                [baseLayer addSublayer:layer.caLayer];


            }else{
                
                NSLog(@"WARNING: DSLayerView doesn't know how to display %@",layer.source.class);
            }
        }
    }
    [CATransaction commit];

    //CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(M_PI / 2.0);
    //[imageLayer setAffineTransform:rotateTransform];
}


-(void)removeAllLayers{
    [_layers removeAllObjects];
}

-(void)removeLayer:(DSLayer*)layer{
    [layer.caLayer removeFromSuperlayer];
    [_layers removeObject:layer];
}


-(DSLayer*)replaceLayerwithPlaceholder:(int)layerIndex{
    [self initLayerArray];
    if(layerIndex>_layers.count){
        NSLog(@"WARNING: No layer at index %i, not replacing anything",layerIndex);
    }else{
        DSLayer* newLayer = [[DSLayer alloc] initWithPlaceholder];
        if(_layers.count != 0){
            DSLayer* existingLayer=[_layers objectAtIndex:layerIndex];
            [newLayer setAlpha:existingLayer.alpha];
            [_layers replaceObjectAtIndex:layerIndex withObject:newLayer];
        }else{
            [_layers addObject:newLayer];
        }
        [self rebuildLayers];
        return newLayer;
    }
    return nil;
}
-(float)alphaForLayer:(long)layerIndex{return 0.0;}
-(void)setAlpha:(float)alpha forLayer:(long)layerIndex{}
-(DSLayer*)replaceLayer:(int)layerIndex withSyphonLayer:(NSString*)syphonName{
    [self initLayerArray];
    if(layerIndex>_layers.count){
        NSLog(@"WARNING: No layer at index %i, not replacing anything",layerIndex);
    }else{
        DSLayer* newLayer = [[DSLayer alloc] initWithSyphonSource:syphonName];
        if(_layers.count != 0){
            DSLayer* existingLayer=[_layers objectAtIndex:layerIndex];
            [newLayer setAlpha:existingLayer.alpha];
            [_layers replaceObjectAtIndex:layerIndex withObject:newLayer];
        }else{
            [_layers addObject:newLayer];
        }
        [self rebuildLayers];
        return newLayer;
    }
    return nil;
}



/////////// Layers ////////////

-(DSLayer*)addEmptyLayer{
    [self initLayerArray];
    DSLayer* newLayer = [[DSLayer alloc] initWithPlaceholder];
    [newLayer setParentView:self];
    [_layers addObject:newLayer];
    [self rebuildLayers];
    return newLayer;
}
-(DSLayer*)addSyphonLayer:(NSString*)syphonName{
    DSLayer* newLayer =[self addSyphonLayer:syphonName withAlpha:1.0];
    [newLayer setParentView:self];
    return newLayer;
}
-(DSLayer*)addSyphonLayer:(NSString*)syphonName withAlpha:(float)alpha{
    [self initLayerArray];
    DSLayer* newLayer = [[DSLayer alloc] initWithSyphonSource:syphonName];
    [newLayer setAlpha:alpha];
    [newLayer setParentView:self];
    [_layers addObject:newLayer];
    [self rebuildLayers];
    return newLayer;
}
-(DSLayer*)addVideoLayer:(NSString *)path{
    return [self addVideoLayer:path withAlpha:1.0 loop:NO];
}
-(DSLayer*)addVideoLayer:(NSString *)path withAlpha:(float)alpha{
    return [self addVideoLayer:path withAlpha:alpha loop:NO];
}
-(DSLayer*)addVideoLayer:(NSString *)path withAlpha:(float)alpha loop:(BOOL)shouldLoop{
    DSLayer* newLayer =[self addImageLayer:path withAlpha:alpha];
    [newLayer setLoop:shouldLoop];
    [newLayer setParentView:self];
    return newLayer;
}
-(DSLayer*)replaceLayer:(int)layerIndex withVideoLayer:(NSString *)path{
    return [self replaceLayer:layerIndex withImageLayer:path];
}
-(DSLayer*)addImageLayer:(NSString*)path{
    return [self addImageLayer:path withAlpha:1.0];
}
-(DSLayer*)addImageLayer:(NSString*)path withAlpha:(float)alpha{
    [self initLayerArray];
    DSLayer* newLayer = [[DSLayer alloc] initWithPath:path];
    [newLayer setAlpha:alpha];
    [newLayer setParentView:self];
    [_layers addObject:newLayer];
    [self rebuildLayers];
    return newLayer;
}

-(DSLayer*)replaceLayer:(int)layerIndex withImageLayer:(NSString*)path{
    [self initLayerArray];
    if(layerIndex>_layers.count){
        NSLog(@"WARNING: No layer at index %i, not replacing anything",layerIndex);
    }else{
        DSLayer* newLayer = [[DSLayer alloc] initWithPath:path];
        if(_layers.count != 0){
            DSLayer* existingLayer=[_layers objectAtIndex:layerIndex];
            [newLayer setAlpha:existingLayer.alpha];
            [_layers replaceObjectAtIndex:layerIndex withObject:newLayer];
        }else{
            [_layers addObject:newLayer];
        }
        [self rebuildLayers];
        return newLayer;
    }
    return nil;
}

-(DSLayer*)addCameraLayer:(AVCaptureDevice*)device withAlpha:(float)alpha{
    [self initLayerArray];
     DSLayer* newLayer = [[DSLayer alloc] initWithAVCaptureDevice:device];
    [newLayer setAlpha:alpha];
    [newLayer setParentView:self];
    [_layers addObject:newLayer];
    [self rebuildLayers];

    return newLayer;
}
-(DSLayer*)addCameraLayer:(AVCaptureDevice*)device{
    return [self addCameraLayer:device withAlpha:1.0];
}
-(DSLayer*)replaceLayer:(int)layerIndex withCameraLayer:(AVCaptureDevice*)device{
    if(layerIndex>_layers.count){
        NSLog(@"WARNING: No layer at index %i, not replacing anything",layerIndex);
    }else{
        DSLayer* newLayer = [[DSLayer alloc] initWithAVCaptureDevice:device];
        if(_layers.count != 0){
            DSLayer* existingLayer=[_layers objectAtIndex:layerIndex];
            [newLayer setAlpha:existingLayer.alpha];
            [_layers replaceObjectAtIndex:layerIndex withObject:newLayer];
        }else{
            [_layers addObject:newLayer];
        }
        [self rebuildLayers];
        return newLayer;
    }
    return nil;
}

-(BOOL)initLayerArray{
    if(!_layers){
        _layers = [[NSMutableArray alloc] init];
        return TRUE;
    }
    return FALSE;
}

// ESC key
- (BOOL)acceptsFirstResponder{return YES;}
-(void)cancelOperation:(id)sender{
    if(_isFullscreen){
        [self makeWindowed];
    }else{
        [self resetLayerTransformation];
        // FIXME: This is a really lame fix to a bug with transformation reset, which needs to get called twice (something wrong with order)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self resetLayerTransformation];
        });
    }
}

-(void)resetLayerTransformation{
    [self setShiftX:baseLayer.frame.size.width/2];
    [self setShiftY:baseLayer.frame.size.height/2];
    [self setScaleZ:1];
    [self setRotation:0];
    [self applyTransformationToBaseLayer];
}

-(void)toggleFullscreen{
    if(_isFullscreen){
        [self makeWindowed];
        [NSCursor unhide];
    }else{
        [self makeFullscreenOn:nil];
        //[NSCursor h];
    }
}

-(void)makeFullscreenOn:(NSScreen*)screenID{
    
    /*
    // Exit if already in fullscreen
    if(_isFullscreen){return;}
    
    parentWindowRect=self.window.frame;
    NSWindow *parentWindow=self.window;
    
    // Aspect ratio
    [self.window setAspectRatio:self.window.screen.frame.size];
    
    // If not specified, default to screen the window is on
    if(!screenID){screenID=self.window.screen;}
    
    NSApplicationPresentationOptions kioskOptions =
    NSApplicationPresentationHideDock +
    NSApplicationPresentationHideMenuBar +
    //NSApplicationPresentationDisableAppleMenu +
    //NSApplicationPresentationDisableProcessSwitching +
    NSApplicationPresentationDisableForceQuit +
    NSApplicationPresentationDisableSessionTermination +
    NSApplicationPresentationDisableHideApplication +
    NSApplicationPresentationDisableMenuBarTransparency;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO],NSFullScreenModeAllScreens,
                             [NSNumber numberWithInteger:kioskOptions],NSFullScreenModeApplicationPresentationOptions,
                             nil];
    
    
    
    [self enterFullScreenMode:screenID withOptions:options];
    [parentWindow orderOut:self];
    _isFullscreen=YES;
     */
}

-(void)makeWindowed{
    /*
    //[self.window setIsVisible:YES];
    
    // Exit fullscreen mode
    [self exitFullScreenModeWithOptions:nil];
    
    NSUInteger windowStyleMask = NSTitledWindowMask|NSResizableWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask;
   // [self setMyWindow:[[NSWindow alloc] initWithContentRect:parentWindowRect styleMask:windowStyleMask backing:NSBackingStoreBuffered defer:NO]];
    [_myWindow setContentView:self];
    [_myWindow makeKeyAndOrderFront:self];
    
    _isFullscreen=NO;
     */
}


// Trackpad ////////////////////////
-(void)scrollWheel:(NSEvent *)event{
    if(!_enableLayerTransformWithTouchpad){return;}
    _shiftY = baseLayer.position.y+(event.deltaY);
    _shiftX = baseLayer.position.x-(event.deltaX);
    [self applyTransformationToBaseLayer];
}

-(void)magnifyWithEvent:(NSEvent *)event{
    if(!_enableLayerTransformWithTouchpad){return;}
    float minScale=0.01;
    float newScale=self.scaleZ+(event.magnification);
    [self setScaleZ:newScale<=minScale?minScale:newScale];
    [self applyTransformationToBaseLayer];
}

- (void)rotateWithEvent:(NSEvent *)event {
    if(!_enableLayerTransformWithTouchpad){return;}
    [self setRotation:_rotation+event.rotation];
    [self applyTransformationToBaseLayer];
}

-(void)applyTransformationToBaseLayer{
    
    CALayer* operateOn;
    if(_selectedLayer){
        operateOn = _selectedLayer.caLayer;
    }else{
        operateOn=baseLayer;
    }
    CGAffineTransform rotation = CGAffineTransformRotate(CGAffineTransformIdentity, _rotation/180*M_PI);
    CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity,_scaleZ,_scaleZ);
    CGAffineTransform rotscale = CGAffineTransformConcat(rotation,scale);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationDuration:0.0];
    
        [operateOn setAffineTransform:rotscale];
        [CATransaction setCompletionBlock:^{
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [CATransaction setAnimationDuration:0.0];
           [operateOn setPosition:CGPointMake(_shiftX,_shiftY)];
            [CATransaction commit];
        }];
    [CATransaction commit];
}

- (void)drawFocusRingMask {
    NSRectFill([self bounds]);
}

- (NSRect)focusRingMaskBounds {
    return [self bounds];
}

-(float)alpha{
    return _alpha;
}
-(void)setAlpha:(float)alpha{
    _alpha = alpha;
    [baseLayer setOpacity:alpha];
}

@end
