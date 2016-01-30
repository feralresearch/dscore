//
//  LayerSource.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>
#import <Opengl/glext.h>
@class DSLayer;

@interface DSLayerSource : NSObject{}

@property DSLayer *parentLayer;
@property NSString* name;
@property BOOL warning;


-(NSImage*) icon;
-(GLuint) glTextureTarget;
-(GLuint) glTexture;
-(NSSize) size;
-(NSSize) glTextureSize;

@end
