//
//  LayerSourceImage.m
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "DSLayerSourceImage.h"
#import "NSImage+util.h"

@implementation DSLayerSourceImage

- (id)initWithPath:(NSString*)path{
    if (self = [super init]){
        NSLog(@"Init Image with path: %@",path);

        _image = [[NSImage alloc] initWithContentsOfFile:path];
        textureDefined=NO;
        
    }
    return self;
}


-(GLuint) glTextureForContext:(NSOpenGLContext*)context{
    if(_image && !textureDefined){
        
        CGLLockContext([context CGLContextObj]);
            [context makeCurrentContext];
            glEnable(GL_TEXTURE_2D);
            glGenTextures(1, &tex);
        CGLUnlockContext([context CGLContextObj]);
        
        [_image loadIntoTexture:tex withContext:context];
        textureDefined=YES;
    }
    return tex;
}
-(GLuint) glTextureTarget{return GL_TEXTURE_2D;}
-(NSSize) glTextureSize{return _image.size;}

// FIXME: not right for JPGs
-(NSSize) size{return _image.size;}

-(void)dealloc{
    _image=nil;
    NSLog(@"DEALLOC");
}

@end
