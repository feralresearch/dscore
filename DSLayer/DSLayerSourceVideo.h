//
//  LayerSourceVideo.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import "DSLayerSource.h"
@class AVPlayer;
@class AVPlayerLayer;
@class AVAsset;
@class AVPlayerItem;
@class AVPlayerItemVideoOutput;
@class AVAssetImageGenerator;
@interface DSLayerSourceVideo : DSLayerSource{
    AVAsset *asset;
    AVPlayerItem *playerItem;
    AVPlayerItemVideoOutput *playerOutput;
    
    BOOL textureDefined;
    
    CVOpenGLTextureRef textureRef;
    CVPixelBufferRef frameBuffer;
    
    CVOpenGLTextureCacheRef textureCache;
    
   GLuint glTextureTarget;
   GLuint glTexture;
   NSSize glTextureSize;
   CIImage *vid_ciimage;
   AVAssetImageGenerator *imageGenerator;
    

}
@property AVPlayer *player;
@property BOOL loop;
@property NSImage* stillFrame;
@property NSString* path;
@property NSOpenGLContext* glContext;

-(CGImageRef)frameGrabAt:(CMTime)time;
-(GLuint) glTextureForContext:(NSOpenGLContext*)context atTime:(const CVTimeStamp *)cvOutputTime;
-(GLuint) glTextureTarget;
-(NSSize) glTextureSize;
-(NSSize) size;
- (id)initWithPath:(NSString*)path;

@property NSImage* frameAsNSImage;
//-(NSImage*)frameAsNSImage;
@end
