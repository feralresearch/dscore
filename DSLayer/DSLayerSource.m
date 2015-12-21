//
//  LayerSource.m
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>
#import <Opengl/glext.h>
#import "DSLayerSource.h"

@implementation DSLayerSource

// Should be overridden by subclass always
-(GLuint) glTextureTarget{return 0;}
-(GLuint) glTexture{return 0;}
-(NSSize) size{return NSZeroSize;}
-(NSSize) glTextureSize{return NSZeroSize;}

@end
