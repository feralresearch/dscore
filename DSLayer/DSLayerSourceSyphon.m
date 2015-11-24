
//
//  DSLayerSourceSyphon.m
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "DSLayerSourceSyphon.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>
#import <Opengl/glext.h>
#import <Syphon/Syphon.h>
#import "DSSyphonMgr.h"
#import "DSSyphonSource.h"
#import "NSImage+util.h"

@implementation DSLayerSourceSyphon

-(id)initWithServerDesc:(NSString*)syphonDesc{
    if (self = [super init]){
        _requestedSyphonServer=syphonDesc;
        syphonMgr = [DSSyphonMgr sharedInstance];

        _syphonSource=[syphonMgr.syphonSourcesByDesc valueForKey:_requestedSyphonServer];


        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveNotification:)
                                                     name:@"SyphonSourceChange"
                                                   object:nil];
        frameCapture = nil;
    }
    return self;
}


-(void) receiveNotification:(NSNotification *) notification{
    if ([[notification name] isEqualToString:@"SyphonSourceChange"]){
        _syphonSource=[syphonMgr.syphonSourcesByDesc valueForKey:_requestedSyphonServer];
    }
}

-(GLuint) glTextureForContext:(NSOpenGLContext*)context{
    if(_syphonSource.syphonClient.hasNewFrame){
        _syphonSource.lastFrame=[NSDate date];
        _syphonSource.syphonImage = [_syphonSource.syphonClient newFrameImageForContext:[context CGLContextObj]];
        tex=_syphonSource.syphonImage.textureName;
        
        if(!frameCapture){
            
            frameCapture = [NSImage imageWithGLTexture:self.glTexture textureType:self.glTextureTarget textureSize:self.glTextureSize context:context flipped:NO];
        }
    }
    return tex;
}
-(GLuint) glTextureTarget{return GL_TEXTURE_RECTANGLE_ARB;}
-(NSSize) glTextureSize{return _syphonSource.syphonImage.textureSize;}
-(NSSize) size{return _syphonSource.syphonImage.textureSize;}
-(void) dealloc{[[NSNotificationCenter defaultCenter] removeObserver:self];}

-(NSImage*)stillFrame{

    return frameCapture;
}


@end
