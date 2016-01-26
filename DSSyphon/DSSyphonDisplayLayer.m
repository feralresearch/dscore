//
//  DSSyphonDisplayLayer.m
//  DSCore
//
//  Created by Andrew on 12/30/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>
#import <Opengl/glext.h>
#import "DSSyphonDisplayLayer.h"
#import "DSLayerSourceSyphon.h"

@implementation DSSyphonDisplayLayer


- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer, use initWithSource:(DSLayerSourceSyphon*)source"
                                 userInfo:nil];
    return nil;
}

- (id) initWithSource:(DSLayerSourceSyphon*)source{
    self = [super init];
    if (self != nil) {
        
        _source=source;
        // Maintain your own draw loop (this layer sets up the whole displaylink thing for us)
        [self setAsynchronous:YES];
    }
    return self;
}

// Drawing code goes here
-(void)drawInCGLContext:(CGLContextObj)glContext pixelFormat:(CGLPixelFormatObj)pixelFormat forLayerTime:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{

    
    
    
    if(!_openGlContext){
        _openGlContext=glContext;
    }
    
    // Set the current context to the one given to us.
    CGLSetCurrentContext(_openGlContext);
    
    
    


    // Reset Matrices (should only do this once)
    glMatrixMode(GL_TEXTURE);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    
    // Clear screen
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    [self glClearScreenFor:self.frame.size];
    
    
    texture = [_source glTextureForContext:[[NSOpenGLContext alloc] initWithCGLContextObj:_openGlContext]];
    if(!_source.warning){
    
        [self glDrawFullscreenQuadWithTexture:texture
                                         type:_source.glTextureTarget
                                         size:_source.glTextureSize
                                        alpha:1.0 //handled by CALayer now
                                   resolution:self.frame.size];
    

    }
    
   

    // Call super to finalize the drawing. By default all it does is call glFlush().
    //[super drawInCGLContext:glContext pixelFormat:pixelFormat forLayerTime:timeInterval displayTime:timeStamp];
    glFlush();

}

// Clear the screen
-(void)glClearScreenFor:(NSSize)resolution{
    
    
    // Make origin lower left with upper right the resolution in question
    glLoadIdentity();
    glOrtho(0, resolution.width, 0, resolution.height, -1.0, 1.0);
    glViewport( 0, 0, resolution.width, resolution.height);
    glTranslatef(-1, -1, 0);
    
    
    
    
    // Clearscreen
    glClearColor(0.0,
                 0.0,
                 0.0,
                 0.0);
    
    
    //glEnable(GL_ALPHA);
    glEnable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    
    glDepthMask(GL_TRUE);
    glDepthFunc(GL_LEQUAL);
    
    glDepthRange(0.0f, 1.0f);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    /*
     FIXME: Something about this blendfunc makes the screen blank
     without it, antialiasing works but you get artifacts
     // enable polygon antialiasing
     glBlendFunc( GL_SRC_ALPHA_SATURATE, GL_ONE );
     glEnable( GL_POLYGON_SMOOTH );
     glDisable( GL_DEPTH_TEST );
     */
    
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
    
}


// Draw a test quad
-(void)glDrawFullscreenQuadTestAtResolution:(NSSize)resolution{
    
    glBegin(GL_QUADS);
    glColor4f(1.0,0.0,0.0,1.0);
    glVertex3f(0,0,0.0);
    
    glColor4f(0.0,1.0,0.0,1.0);
    glVertex3f(resolution.width+1,0,0.0);
    
    glColor4f(0.0,0.0,1.0,1.0);
    glVertex3f(resolution.width+1,resolution.height+1,0.0);
    
    glColor4f(0.0,0.0,0.0,1.0);
    glVertex3f(0,resolution.height+1,0.0);
    glEnd();
}

// Draw a fullscreen quad
-(void)glDrawFullscreenQuadWithTexture:(GLuint)tex
                                  type:(GLuint)textureType
                                  size:(NSSize)textureSize
                                 alpha:(float)alpha
                            resolution:(NSSize)resolution{
    
    
    glBindTexture(textureType,tex);
    glEnable(textureType);
    glColor4f(1.0,1.0,1.0,alpha);
    glBegin(GL_QUADS);
    
    // 2D texture coords are normalized
    if(textureType == GL_TEXTURE_2D){
        // Texture 2D coordinate system is NOT altered
        // FIXME: Note we +1 on resolution because otherwise there was a 1px border
        
        glTexCoord2f(0.0, 0.0);
        glVertex3f(0.0, 0.0, 0.0);
        
        glTexCoord2f(1.0, 0.0);
        glVertex3f(resolution.width+1, 0.0, 0.0);
        
        glTexCoord2f(1.0, 1.0);
        glVertex3f(resolution.width+1, resolution.height+1, 0.0);
        
        glTexCoord2f(0.0, 1.0);
        glVertex3f(0.0, resolution.height+1, 0.0);
        
        
    // RECTANGLE textures use pixel coordinates
    }else{
        
        glTexCoord2f(0.0, 0.0);
        glVertex3f(0.0, 0.0, 0.0);
        
        glTexCoord2f(textureSize.width, 0.0);
        glVertex3f(resolution.width+1, 0.0, 0.0);
        
        glTexCoord2f(textureSize.width, textureSize.height);
        glVertex3f(resolution.width+1, resolution.height+1, 0.0);
        
        glTexCoord2f(0.0, textureSize.height);
        glVertex3f(0.0, resolution.height+1, 0.0);
        
    }
    
    
    glEnd();
    glDisable(textureType);
}



@end
