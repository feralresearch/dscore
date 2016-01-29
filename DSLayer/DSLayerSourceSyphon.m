
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
        syphonMgr = [DSSyphonMgr sharedDSSyphonMgr];

        _syphonSource=[syphonMgr.syphonSourcesByDesc valueForKey:_requestedSyphonServer];

        [self setWarning:!_syphonSource];
        
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

        

        if(!_syphonSource){
            [self setWarning:YES];
            NSLog(@"WARNING: Requested syphon source '%@' is not available, these are:",_requestedSyphonServer);
            for(NSString* syphonSourceName in syphonMgr.syphonSourcesByDesc){
                NSLog(@"--- %@",syphonSourceName);
            }
        }
    }
}

-(GLuint) glTextureForContext:(NSOpenGLContext*)context{
    if(_syphonSource.syphonClient.hasNewFrame){
         [self setWarning:NO];
        _syphonSource.lastFrame=[NSDate date];
        _syphonSource.syphonImage = [_syphonSource.syphonClient newFrameImageForContext:[context CGLContextObj]];
        tex=_syphonSource.syphonImage.textureName;
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

-(NSImage*)sourceIcon{
    return [_syphonSource.syphonClient.serverDescription valueForKey:@"SyphonServerDescriptionIconKey"];
}

@end
