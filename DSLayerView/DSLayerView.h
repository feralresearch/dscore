//
//  DSLayerView.h
//
//  Created by Andrew on 11/12/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DSLayer;



@interface DSLayerView : NSOpenGLView{
    const CVTimeStamp *cvOutputTime;

    int syphonServerCount;
    NSRect parentWindowRect;
    float rotation;    
    CVDisplayLinkRef displayLink;
}
@property NSWindow* myWindow;
@property NSColor *backgroundColor;
@property float overlayAlpha;
@property (readonly) BOOL isFullscreen;
@property (readonly) NSMutableArray *layers;

-(void)toggleFullscreen;
-(void)rotateView;

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


-(float)alphaForLayer:(int)layerIndex;
-(void)setAlpha:(float)alpha forLayer:(int)layerIndex;

@end

