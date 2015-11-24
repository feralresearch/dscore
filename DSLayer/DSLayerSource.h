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

@interface DSLayerSource : NSObject



@property NSString* name;

-(GLuint) glTextureTarget;
-(GLuint) glTexture;
-(NSSize) size;
-(NSSize) glTextureSize;

@end
