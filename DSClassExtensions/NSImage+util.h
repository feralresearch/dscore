//
//  NSImage+util.h
//  FRCLassExtensions
//
//  Created by Andrew on 8/25/13.
//  Copyright (c) 2013 Vox Fera. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface NSImage (util) {}

-(NSImage*)cropToSquare;
-(NSImage*)cropToSquarePreserveTransparency:(BOOL)preserveTransparency;
-(NSImage*)resizeTo:(NSSize)newSize;
-(void) writePNGToFile:(NSString*)filePath;
-(NSImage *) imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (NSImage*)scaleToWidth:(NSInteger)newWidth;
- (NSImage*)scaleToHeight:(NSInteger)newHeight;

-(NSSize)actualSize;
-(NSSize)dimension;
+(NSImage*)imageWithGLTexture:(GLuint)glTexture
                  textureType:(GLuint)target
                  textureSize:(NSSize)imageSize
                      context:(NSOpenGLContext*)openGLContext
                      flipped:(BOOL)flipped;
-(void)loadIntoTexture:(GLuint)glTexture withContext:(NSOpenGLContext*)openGLContext;

@end
