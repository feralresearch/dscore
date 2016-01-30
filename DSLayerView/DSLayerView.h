//
//  DSLayerView.h
//  DSCore
//
//  Created by Andrew on 12/30/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//
#import <Cocoa/Cocoa.h>
@class DSLayer;
@class SyphonServer;
@class AVCaptureDevice;

@interface DSLayerView : NSView{
    CALayer *baseLayer;
    NSPoint centeredPosition;
    NSMutableArray* filterArray;
    float _alpha;
}
@property NSWindow* myWindow;
@property NSColor *backgroundColor;

@property float shiftX;
@property float shiftY;
@property float scaleZ;
@property float rotation;
@property (readonly) BOOL isFullscreen;
@property (readonly) NSMutableArray *layers;
@property BOOL enableLayerTransformWithTouchpad;
@property NSString* syphonOutputName;
@property NSSize syphonOutputResolution;

@property DSLayer* selectedLayer;

-(NSMutableArray*)filterArray;
-(void)setFilterArray:(NSMutableArray *)filterArray;
-(void)addFilter:(CIFilter*)filter;
-(void)removeFilter:(CIFilter*)filter;
-(void)removeAllFilters;

-(void)toggleFullscreen;
-(void)removeAllLayers;
-(DSLayer*)addEmptyLayer;
-(DSLayer*)replaceLayerwithPlaceholder:(int)layerIndex;
-(void)removeLayer:(DSLayer*)layer;

-(DSLayer*)addSyphonLayer:(NSString*)syphonName withAlpha:(float)alpha;
-(DSLayer*)addSyphonLayer:(NSString*)syphonName;
-(DSLayer*)replaceLayer:(int)layerIndex withSyphonLayer:(NSString*)syphonName;

-(DSLayer*)addImageLayer:(NSString*)path;
-(DSLayer*)addImageLayer:(NSString*)path withAlpha:(float)alpha;
-(DSLayer*)replaceLayer:(int)layerIndex withImageLayer:(NSString*)path;

-(DSLayer*)addVideoLayer:(NSString*)path;
-(DSLayer*)addVideoLayer:(NSString *)path withAlpha:(float)alpha;
-(DSLayer*)addVideoLayer:(NSString *)path withAlpha:(float)alpha loop:(BOOL)shouldLoop;
-(DSLayer*)replaceLayer:(int)layerIndex withVideoLayer:(NSString*)path;

-(DSLayer*)addCameraLayer:(AVCaptureDevice*)device withAlpha:(float)alpha;
-(DSLayer*)addCameraLayer:(AVCaptureDevice*)device;
-(DSLayer*)replaceLayer:(int)layerIndex withCameraLayer:(AVCaptureDevice*)device;

-(DSLayer*)addTextLayer:(NSString*)string withAlpha:(float)alpha;
-(DSLayer*)addTextLayer:(NSString*)string;
-(DSLayer*)replaceLayer:(int)layerIndex withTextLayer:(NSString*)string;

// Specific layer alpha
-(float)alphaForLayer:(long)layerIndex;
-(void)setAlpha:(float)alpha forLayer:(long)layerIndex;

// Base layer alpha
-(void)setAlpha:(float)alpha;
-(float)alpha;

-(void)moveLayer:(DSLayer*)layer toPosition:(int)position;
@end
