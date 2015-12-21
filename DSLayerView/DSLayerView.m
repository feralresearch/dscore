//
//  DSLayerView.m
//
//  Created by Andrew on 11/12/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DSLayerView.h"
#import "DSLayer.h"
#import "DSLayerSource.h"
#import "DSLayerSourceSyphon.h"
#import "DSSyphonSource.h"
#import "DSLayerSourceImage.h"
#import "DSLayerSourceVideo.h"

#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>
#import <Opengl/glext.h>
#import <Syphon/Syphon.h>
#import "NSImage+util.h"


@implementation DSLayerView

- (void)commonInit{
    // do any initialization that's common to both -initWithFrame:
    // and -initWithCoder: in this method
    [self setBackgroundColor:[[NSColor blackColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace] ];
    _overlayAlpha=0;
    [self setRotation:0];
    [self setBackgroundColor:[[NSColor blackColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
    [self setShiftX:0];
    [self setShiftY:0];
    [self setScaleZ:1];
    
    [self setEnableLayerTransformWithTouchpad:NO];
    [self setSyphonOutputName:nil];
    
    syphonFBO=-1;
}

- (id)initWithFrame:(CGRect)aRect{
    if ((self = [super initWithFrame:aRect])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

-(float)alphaForLayer:(long)layerIndex{
    DSLayer* layer = [_layers objectAtIndex:layerIndex];
    if(layer){
        return layer.alpha;
    }
    return -1;
}
-(void)setAlpha:(float)alpha forLayer:(long)layerIndex{
    DSLayer* layer = [_layers objectAtIndex:layerIndex];
    if(layer){
        [layer setAlpha:alpha];
    }
}

-(void)scrollWheel:(NSEvent *)event{
     [self setShiftY:self.shiftY+(event.deltaY)];
    [self setShiftX:self.shiftX-(event.deltaX)];
}

-(void)magnifyWithEvent:(NSEvent *)event{
    float minScale=0.1;
    if(!_enableLayerTransformWithTouchpad){return;}
    float newScale=self.scaleZ+(event.magnification);
    [self setScaleZ:newScale<=minScale?minScale:newScale];
}

- (void)rotateWithEvent:(NSEvent *)event {
    if(!_enableLayerTransformWithTouchpad){return;}
    [self setRotation:_rotation+event.rotation];
}


// Remove all
-(void)removeAllLayers{
    [_layers removeAllObjects];
}

// Add Syphon

-(DSLayer*)addEmptyLayer{
  @synchronized(_layers){
    if(!_layers){
        _layers = [[NSMutableArray alloc] init];
    }
    DSLayer* newLayer = [[DSLayer alloc] initWithPlaceholder];
    [_layers addObject:newLayer];
    return newLayer;
  }
}

-(DSLayer*)addSyphonLayer:(NSString*)syphonName{
    return [self addSyphonLayer:syphonName withAlpha:1.0];
}
-(DSLayer*)addSyphonLayer:(NSString*)syphonName withAlpha:(float)alpha{
    @synchronized(_layers){
        if(!_layers){
             _layers = [[NSMutableArray alloc] init];
        }
        DSLayer* newLayer = [[DSLayer alloc] initWithSyphonSource:syphonName];
        [newLayer setAlpha:alpha];
        [_layers addObject:newLayer];
        return newLayer;
    }
}
-(DSLayer*)replaceLayer:(int)layerIndex withSyphonLayer:(NSString*)syphonName{
    @synchronized(_layers){
        if(!_layers){
            _layers = [[NSMutableArray alloc] init];
        }
        
        if(layerIndex>_layers.count){
            NSLog(@"WARNING: No layer at index %i, not replacing anything",layerIndex);
        }else{
            DSLayer* newLayer = [[DSLayer alloc] initWithSyphonSource:syphonName];
            if(_layers.count != 0){
                DSLayer* existingLayer=[_layers objectAtIndex:layerIndex];
                [newLayer setAlpha:existingLayer.alpha];
                [_layers replaceObjectAtIndex:layerIndex withObject:newLayer];
            }else{
                [_layers addObject:newLayer];
            }
            
            return newLayer;
        }
        return nil;
    }
}

-(DSLayer*)addVideoLayer:(NSString *)path{
    return [self addImageLayer:path];
}
-(DSLayer*)addVideoLayer:(NSString *)path withAlpha:(float)alpha{
    return [self addImageLayer:path withAlpha:alpha];
}
-(DSLayer*)replaceLayer:(int)layerIndex withVideoLayer:(NSString *)path{
    return [self replaceLayer:layerIndex withImageLayer:path];
}

-(DSLayer*)addImageLayer:(NSString*)path{
    return [self addImageLayer:path withAlpha:1.0];
}
-(DSLayer*)addImageLayer:(NSString*)path withAlpha:(float)alpha{
    @synchronized(_layers){
        if(!_layers){
            _layers = [[NSMutableArray alloc] init];
        }
        DSLayer* newLayer = [[DSLayer alloc] initWithPath:path];
        [newLayer setAlpha:alpha];
        [_layers addObject:newLayer];
        return newLayer;
    }
}
-(DSLayer*)replaceLayer:(int)layerIndex withImageLayer:(NSString*)path{
    @synchronized(_layers){
        if(!_layers){
            _layers = [[NSMutableArray alloc] init];
        }
        
        if(layerIndex>_layers.count){
            NSLog(@"WARNING: No layer at index %i, not replacing anything",layerIndex);
        }else{
            DSLayer* newLayer = [[DSLayer alloc] initWithPath:path];
            if(_layers.count != 0){
                DSLayer* existingLayer=[_layers objectAtIndex:layerIndex];
                [newLayer setAlpha:existingLayer.alpha];
                [_layers replaceObjectAtIndex:layerIndex withObject:newLayer];
            }else{
                [_layers addObject:newLayer];
            }
            
            return newLayer;
        }
        return nil;
    }
}

-(DSLayer*)replaceLayerwithPlaceholder:(int)layerIndex{
    @synchronized(_layers){
        if(!_layers){
            _layers = [[NSMutableArray alloc] init];
        }
        
        if(layerIndex>_layers.count){
            NSLog(@"WARNING: No layer at index %i, not replacing anything",layerIndex);
        }else{
            DSLayer* newLayer = [[DSLayer alloc] initWithPlaceholder];
            if(_layers.count != 0){
                DSLayer* existingLayer=[_layers objectAtIndex:layerIndex];
                [newLayer setAlpha:existingLayer.alpha];
                [_layers replaceObjectAtIndex:layerIndex withObject:newLayer];
            }else{
                [_layers addObject:newLayer];
            }
            
            return newLayer;
        }
        return nil;
    }
}


// Called by displyalink
- (void)drawView{



    NSOpenGLContext  *currentContext;
    currentContext = [self openGLContext];
    [currentContext makeCurrentContext];
    CGLLockContext([currentContext CGLContextObj]);
    
    /*
    // SETUP Syphon FBO
    if(syphonFBO == -1){
        [self setSyphonOutputResolution:NSMakeSize(1024, 768)];
        [self createFBO:syphonFBO
             renderInto:syphonFBOTex
                   size:_syphonOutputResolution withDepth:nil];
    }
     */


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



        // If we have at least one layer
        if([_layers count] > 0){

            //If the quad is going to be smaller than the window, split the extra space on either side
            DSLayer* firstLayer = [_layers firstObject];
            
            // If the first layer size is 0,0 then use the next layer with actual dimensions
            if(NSEqualSizes(firstLayer.source.size, NSZeroSize)){
                for (DSLayer* layer in _layers){
                    if (!NSEqualSizes(layer.source.size, NSZeroSize)) {
                        firstLayer=layer;
                    }
                }
            }
            
            // Calculate offset and center the image
            float ratio = firstLayer.source.size.width/firstLayer.source.size.height;
            float maxWidth=self.frame.size.height*ratio;
            float maxHeight=maxWidth/ratio;
            float offsetX=0;
            float offsetY=0;
            if(self.frame.size.width > maxWidth){
                offsetX = (self.frame.size.width-maxWidth)/2;
            }
            if(self.frame.size.height > maxHeight){
                offsetY = (self.frame.size.height-maxHeight)/2;
            }
            glTranslatef(offsetX+_shiftX,offsetY+_shiftY,1.0);
            
            // Apply rotation
            glTranslatef(+((self.frame.size.width*_scaleZ)/2), +((self.frame.size.height*_scaleZ)/2), 0);
            glRotatef(_rotation, 0, 0, 1);
            glTranslatef(-((self.frame.size.width*_scaleZ)/2), -((self.frame.size.height*_scaleZ)/2), 0);
            
            //gluPerspective (50.0*1.0, (float)self.frame.size.width/(float)self.frame.size.height, 20, 200);
            
            //Set aspect ratio to match screen
            [self.window setAspectRatio:self.window.screen.frame.size];
            
            @synchronized(_layers){
                for (DSLayer* layer in _layers){
                    
                    // Syphon
                    if([layer.source isKindOfClass:[DSLayerSourceSyphon class]]){

                         DSLayerSourceSyphon* syphonSourcedLayer = (DSLayerSourceSyphon*)layer.source;

                         if(!syphonSourcedLayer.syphonSource.hasWarning){

                            [self glDrawFullscreenQuadWithTexture:[syphonSourcedLayer glTextureForContext:self.openGLContext]
                                                             type:syphonSourcedLayer.glTextureTarget
                                                             size:syphonSourcedLayer.size
                                                            alpha:layer.alpha
                                                       resolution:NSMakeSize(maxWidth*_scaleZ, maxHeight*_scaleZ)];
                             
                             
                             
                    
                             
                             
                             

                         }else{
                             NSLog(@"SYPHON WARNING");
                             [self glDrawFullscreenQuadWithTexture:[syphonSourcedLayer glTextureForContext:self.openGLContext]
                                                              type:syphonSourcedLayer.glTextureTarget
                                                              size:syphonSourcedLayer.size
                                                             alpha:layer.alpha
                                                        resolution:NSMakeSize(maxWidth*_scaleZ, maxHeight*_scaleZ)];
                         }
                    
                    // Image
                    } else if([layer.source isKindOfClass:[DSLayerSourceImage class]]){
                        
                            DSLayerSourceImage* imgSourcedLayer = (DSLayerSourceImage*)layer.source;
                            [self glDrawFullscreenQuadWithTexture:[imgSourcedLayer glTextureForContext:self.openGLContext]
                                                             type:imgSourcedLayer.glTextureTarget
                                                             size:imgSourcedLayer.size
                                                            alpha:layer.alpha
                                                       resolution:NSMakeSize(maxWidth*_scaleZ, maxHeight*_scaleZ)];
                    }
                }
            }
            
           
            
        }

    

        glFlush();

    [currentContext flushBuffer];
    CGLUnlockContext([currentContext CGLContextObj]);


}


// Clear the screen
-(void)glClearScreenFor:(NSSize)resolution{


    // Make origin lower left with upper right the resolution in question
    glLoadIdentity();
    glOrtho(0, resolution.width, 0, resolution.height, -1.0, 1.0);
    glViewport( 0, 0, resolution.width, resolution.height);
    glTranslatef(-1, -1, 0);
    
    


    // Clearscreen
    glClearColor([_backgroundColor redComponent],
                 [_backgroundColor greenComponent],
                 [_backgroundColor blueComponent],
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
-(void)glDrawFullscreenQuadWithTexture:(GLuint)texture
                                  type:(GLuint)textureType
                                  size:(NSSize)textureSize
                                 alpha:(float)alpha
                            resolution:(NSSize)resolution{


    glBindTexture(textureType,texture);
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




// ESC key
- (void)cancelOperation:(id)sender{
    [self makeWindowed];
}

-(void)toggleFullscreen{
    if(_isFullscreen){
        [self makeWindowed];
        [NSCursor unhide];
    }else{
        [self makeFullscreenOn:nil];
        //[NSCursor h];
    }
}


-(void)makeFullscreenOn:(NSScreen*)screenID{


    // Exit if already in fullscreen
    if(_isFullscreen){return;}

    parentWindowRect=self.window.frame;
    NSWindow *parentWindow=self.window;

    // Aspect ratio
    [self.window setAspectRatio:self.window.screen.frame.size];

    // If not specified, default to screen the window is on
    if(!screenID){screenID=self.window.screen;}

    NSApplicationPresentationOptions kioskOptions =
    NSApplicationPresentationHideDock +
    NSApplicationPresentationHideMenuBar +
    //NSApplicationPresentationDisableAppleMenu +
    //NSApplicationPresentationDisableProcessSwitching +
    NSApplicationPresentationDisableForceQuit +
    NSApplicationPresentationDisableSessionTermination +
    NSApplicationPresentationDisableHideApplication +
    NSApplicationPresentationDisableMenuBarTransparency;

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO],NSFullScreenModeAllScreens,
                             [NSNumber numberWithInteger:kioskOptions],NSFullScreenModeApplicationPresentationOptions,
                             nil];



    [self enterFullScreenMode:screenID withOptions:options];
    [parentWindow orderOut:self];
    _isFullscreen=YES;
}

-(void)makeWindowed{
    //[self.window setIsVisible:YES];

    // Exit fullscreen mode
    [self exitFullScreenModeWithOptions:nil];

    NSUInteger windowStyleMask = NSTitledWindowMask|NSResizableWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask;
    [self setMyWindow:[[NSWindow alloc] initWithContentRect:parentWindowRect styleMask:windowStyleMask backing:NSBackingStoreBuffered defer:NO]];
    [_myWindow setContentView:self];
    [_myWindow makeKeyAndOrderFront:self];

    _isFullscreen=NO;
}



// Displaylink boilerplate (https://developer.apple.com/library/mac/qa/qa1385/_index.html)
// for a different approach see https://developer.apple.com/library/mac/samplecode/BasicMultiGPUSample/Listings/MyOpenGLView_m.html
- (void)prepareOpenGL{
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];

    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);

    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void * _Nullable)(self));

    // Set the display link for the current renderer
    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);

    // Activate the display link
    CVDisplayLinkStart(displayLink);
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext){
    CVReturn result = [(__bridge DSLayerView*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime{
    // Add your drawing codes here
    [self drawView];
    return kCVReturnSuccess;
}

- (void)dealloc{
    // Release the display link
    CVDisplayLinkRelease(displayLink);
}


-(void)syphonSendTexture:(GLuint)tex as:(NSString*)name{
    
    if(! [self openGLContext]){
        NSLog(@"ERROR: Cannot send syphon without opengl context");
        return;
    }
    
    if(!syphonServer){
        
        syphonServer = [[SyphonServer alloc] initWithName:_syphonOutputName context:[[self openGLContext] CGLContextObj] options:nil];
        if(!syphonServer){
            NSLog(@"INTERNAL ERROR: Cannot initializing Syphon server in context");}
    }
    if(syphonServer.hasClients){
        // Bind texture
        glBindTexture(GL_TEXTURE_2D, tex);
        
        // Do whatever you want with the texture here...
        [syphonServer publishFrameTexture:tex
                            textureTarget:GL_TEXTURE_2D
                              imageRegion:NSMakeRect(0,0,640,480)
                        textureDimensions:NSMakeSize(640,480)
                                  flipped:YES];
        // Free the texture memory
        glDeleteTextures(1, &tex);
    }
}

// Create a FBO for offscreen rendering
-(void)createFBO:(GLuint)renderFbo
      renderInto:(GLuint)renderTexture
            size:(NSSize)renderSize
       withDepth:(NSNumber*)renderDepthBuffer{
    
    // Sanity check
    if(!renderSize.width >0){NSLog(@"INTERNAL ERROR: Cannot create FBO with zero dimensions");return;}
    
    // Bind
    glBindFramebuffer(GL_FRAMEBUFFER, renderFbo);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, renderTexture);
    
    // Give an empty image to OpenGL ( the last "0" )
    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0,GL_RGBA, renderSize.width,renderSize.height, 0,GL_RGBA, GL_UNSIGNED_BYTE, 0);
    
    // FIXME: I don't know what this does (something mipmap)
    glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // Optional depth buffer
    if(renderDepthBuffer){
        GLuint fboDepthrenderbuffer = [renderDepthBuffer intValue];
        glGenRenderbuffers(1, &fboDepthrenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, fboDepthrenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, renderSize.width,renderSize.height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, fboDepthrenderbuffer);
    }
    
    // Set "renderedTexture" as our colour attachement #0
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_RECTANGLE_ARB, renderTexture, 0);
    
    // Set the list of draw buffers.
    GLenum DrawBuffers[1] = {GL_COLOR_ATTACHMENT0};
    glDrawBuffers(1, DrawBuffers); // "1" is the size of DrawBuffers
    
    // Always check that our framebuffer is ok
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
        NSLog(@"ERROR: Framebuffer not ok");
    }
    
}

@end
