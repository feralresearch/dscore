//
//  LayerSourceVideo.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DSLayerSource.h"
@class AVPlayer;
@class AVPlayerLayer;
@class AVAsset;
@class AVPlayerItem;
@class AVPlayerItemVideoOutput;

@interface DSLayerSourceVideo : DSLayerSource{
    AVPlayer *player;
    AVPlayerLayer *playerLayer;
    AVAsset *asset;
    AVPlayerItem *playerItem;
    AVPlayerItemVideoOutput *playerOutput;
    
    BOOL textureDefined;
    
    CVOpenGLTextureRef textureRef;
    CVPixelBufferRef frameBuffer;
    
    CIContext *ciContext;
    CVOpenGLTextureCacheRef textureCache;
    
   GLuint glTextureTarget;
   GLuint glTexture;
   NSSize glTextureSize;
   CIImage *vid_ciimage;

}
@property BOOL loop;
@property NSImage* stillFrame;
@property NSString* path;
@property NSOpenGLContext* glContext;

-(GLuint) glTextureForContext:(NSOpenGLContext*)context atTime:(const CVTimeStamp *)cvOutputTime;
-(GLuint) glTextureTarget;
-(NSSize) glTextureSize;
-(NSSize) size;
- (id)initWithPath:(NSString*)path;

@property NSImage* frameAsNSImage;
//-(NSImage*)frameAsNSImage;
@end
