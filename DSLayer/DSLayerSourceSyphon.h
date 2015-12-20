//
//  LayerSourceSyphon.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "DSLayerSource.h"
@class NSOpenGLContext;
@class SyphonClient;
@class SyphonImage;
@class DSSyphonMgr;
@class DSSyphonSource;

@interface DSLayerSourceSyphon : DSLayerSource{
    DSSyphonMgr *syphonMgr;
    GLuint tex;
    NSImage* frameCapture;
}

@property (readonly) NSString* requestedSyphonServer;
@property DSSyphonSource* syphonSource;

-(id)initWithServerDesc:(NSString*)syphonDesc;
-(GLuint) glTextureForContext:(NSOpenGLContext*)context;
-(GLuint) glTextureTarget;
-(NSSize) glTextureSize;
-(NSSize) size;
-(NSImage*)stillFrame;
-(NSImage*)sourceIcon;
@end
