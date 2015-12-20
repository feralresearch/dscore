//
//  DSLayerView.h
//
//  Created by Andrew on 11/12/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Syphon/Syphon.h>
@class DSLayer;
@class  SyphonServer;

@interface DSLayerView : NSOpenGLView{
    const CVTimeStamp *cvOutputTime;
    int syphonServerCount;
    NSRect parentWindowRect;
    CVDisplayLinkRef displayLink;
    SyphonServer *syphonServer;
    
    GLuint syphonFBO;
    GLuint syphonFBOTex;
    
}
@property NSWindow* myWindow;
@property NSColor *backgroundColor;
@property float overlayAlpha;
@property float shiftX;
@property float shiftY;
@property float scaleZ;
@property float rotation;
@property (readonly) BOOL isFullscreen;
@property (readonly) NSMutableArray *layers;
@property BOOL enableLayerTransformWithTouchpad;

@property NSString* syphonOutputName;
@property NSSize syphonOutputResolution;

-(void)toggleFullscreen;

-(void)removeAllLayers;
-(DSLayer*)addEmptyLayer;
-(DSLayer*)replaceLayerwithPlaceholder:(int)layerIndex;

-(DSLayer*)addSyphonLayer:(NSString*)syphonName withAlpha:(float)alpha;
-(DSLayer*)addSyphonLayer:(NSString*)syphonName;
-(DSLayer*)replaceLayer:(int)layerIndex withSyphonLayer:(NSString*)syphonName;

-(DSLayer*)addImageLayer:(NSString*)path;
-(DSLayer*)addImageLayer:(NSString*)path withAlpha:(float)alpha;
-(DSLayer*)replaceLayer:(int)layerIndex withImageLayer:(NSString*)path;

-(DSLayer*)addVideoLayer:(NSString*)path;
-(DSLayer*)addVideoLayer:(NSString*)path withAlpha:(float)alpha;
-(DSLayer*)replaceLayer:(int)layerIndex withVideoLayer:(NSString*)path;


-(float)alphaForLayer:(long)layerIndex;
-(void)setAlpha:(float)alpha forLayer:(long)layerIndex;

@end

