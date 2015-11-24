//
//  LayerSourceImage.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "DSLayerSource.h"
@class NSOpenGLContext;

@interface DSLayerSourceImage : DSLayerSource{
    GLuint tex;
    BOOL textureDefined;
}
@property     NSImage *image;

@property NSString* path;

- (id)initWithPath:(NSString*)path;
-(GLuint) glTextureForContext:(NSOpenGLContext*)context;
-(GLuint) glTextureTarget;
-(NSSize) glTextureSize;
-(NSSize) size;
@end
