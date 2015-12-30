 //
//  NSImage+util.h
//  FRCLassExtensions
//
//  Created by Andrew on 8/25/13.
//  Copyright (c) 2013 Vox Fera. All rights reserved.
//

#import "NSImage+util.h"
#import <AppKit/AppKit.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>

@implementation NSImage (util)

// Resizes
- (NSImage*)resizeTo:(NSSize)newSize{

    
    // Make sure image isn't 0,0 or float size
    if(CGSizeEqualToSize(_size,NSZeroSize)==1){return nil;}
    newSize=NSMakeSize((int)newSize.width, (int)newSize.height);
    
    NSImage *sourceImage = self;
    
    // Report an error if the source isn't a valid image
    if (!sourceImage){
        NSLog(@"Invalid Image");
    }else{
        NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
        [smallImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.];
        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}


- (NSImage*)scaleToWidth:(NSInteger)newWidth{
    
    return [self resizeTo:NSMakeSize(newWidth, self.size.height*(newWidth/self.size.width))];
}
- (NSImage*)scaleToHeight:(NSInteger)newHeight{
    return [self resizeTo:NSMakeSize(self.size.width*(newHeight/self.size.height),newHeight)];
}

// Crops to center square
-(NSImage*)cropToSquare{
    return [self cropToSquarePreserveTransparency:NO];
}
-(NSImage*)cropToSquarePreserveTransparency:(BOOL)preserveTransparency{
    if(self.size.width ==0){return nil;}
    NSImage* inputImage=self;
    // If already a square return unmodified
    if(inputImage.size.width==inputImage.size.height){
        return inputImage;
    }else{
        
        NSRect cropRect;
        int smallestMax;
        
        // Width is largest
        if(inputImage.size.width > inputImage.size.height){
            
            smallestMax=inputImage.size.height;
            
            cropRect=NSMakeRect((int)((inputImage.size.width-smallestMax)/2), 0, smallestMax, smallestMax);
            
            // Height is largest
        }else{
            smallestMax=inputImage.size.width;
            
            
            cropRect=NSMakeRect(0,(int)((inputImage.size.height-smallestMax)/2), smallestMax, smallestMax);
            
        }
        
        
        
        NSImage* squareImage = [[NSImage alloc] initWithSize:NSMakeSize(smallestMax,smallestMax)];
        [squareImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [inputImage drawAtPoint:NSZeroPoint
                       fromRect:cropRect
                      operation:NSCompositeCopy fraction:1.];
        
        [squareImage unlockFocus];


        // Remove transparency
        if(!preserveTransparency){

            NSImage *whiteSquare = [[NSImage alloc] initWithSize:squareImage.size];
            [whiteSquare lockFocus];
            [[NSColor whiteColor] setFill];
            [NSBezierPath fillRect:NSMakeRect(0, 0, whiteSquare.size.width, whiteSquare.size.height)];
            [whiteSquare unlockFocus];


            [whiteSquare lockFocus];
                [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
                [squareImage drawInRect:NSMakeRect(0,0, whiteSquare.size.width, whiteSquare.size.height)
                               fromRect:NSZeroRect
                              operation:NSCompositeSourceOver
                               fraction:1.0];
            [whiteSquare unlockFocus];
            return whiteSquare;
        }

        return squareImage;
    }
}

// Writes to disk
- (void) writePNGToFile:(NSString*)filePath{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
    [imageData writeToFile:filePath atomically:NO];
}




// From  http://theocacao.com/document.page/350
- (NSBitmapImageRep *)bitmap;{
    NSSize imgSize = [self size];
    
    if(CGSizeEqualToSize(imgSize,NSZeroSize)==1){return nil;}
    
    NSBitmapImageRep* bitmap = [NSBitmapImageRep alloc];
    
    [self lockFocus];
    bitmap = [bitmap initWithFocusedViewRect:NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height)];
    [self unlockFocus];
    
    return bitmap;
}

- (CIImage *)CIImage{
    return [[CIImage alloc] initWithBitmapImageRep:[self bitmap]];
}



- (NSImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer.
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer.
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height.
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space.
    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL) {
            // Handle the error appropriately.
            return nil;
        }
    }
    
    // Get the base address of the pixel buffer.
    uint8_t *baseAddress = malloc( bytesPerRow * height );
    memcpy( baseAddress, CVPixelBufferGetBaseAddress(imageBuffer), bytesPerRow * height );
    
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply.
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow,
                                       colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    // Create and return an image object to represent the Quartz image.
    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:NSMakeSize(CVPixelBufferGetWidth(imageBuffer),CVPixelBufferGetHeight(imageBuffer))];
    CGImageRelease(cgImage);
    free(baseAddress);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

-(NSSize)actualSize{return [self dimension];}
-(NSSize)dimension{
    NSArray * imageReps = self.representations;
    NSInteger width = 0;
    NSInteger height = 0;
    for (NSImageRep * imageRep in imageReps) {
        if ([imageRep pixelsWide] > width) width = [imageRep pixelsWide];
        if ([imageRep pixelsHigh] > height) height = [imageRep pixelsHigh];
    }
    return NSMakeSize(width,height);
}

-(void)loadIntoTexture:(GLuint)glTexture withContext:(NSOpenGLContext*)openGLContext{
    
    // If we are passed an empty image, just quit
    NSImage *inputImage=self;
    if (inputImage == nil){return;}
    
    
    CGLLockContext([openGLContext CGLContextObj]);
    [openGLContext makeCurrentContext];
    
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, glTexture);
    
    
    //  Aquire and flip the data
    NSSize imageSize = inputImage.size;
    //FIXME:
    // Commented out the isFlipped
    //if (![inputImage isFlipped]) {
        NSImage *drawImage = [[NSImage alloc] initWithSize:imageSize];
        NSAffineTransform *transform = [NSAffineTransform transform];
        
        [drawImage lockFocus];
        
        [transform translateXBy:0 yBy:imageSize.height];
        [transform scaleXBy:1 yBy:-1];
        [transform concat];
        
        [inputImage drawAtPoint:NSZeroPoint
                       fromRect:(NSRect){NSZeroPoint, imageSize}
                      operation:NSCompositeCopy
                       fraction:1];
        
        [drawImage unlockFocus];
        
        inputImage = drawImage;
    //}
    
    // THIS iS SLOOOOW
    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithData:[inputImage TIFFRepresentation]];
    
    //  Now make a texture out of the bitmap data
    // Set proper unpacking row length for bitmap.
    glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)[bitmap pixelsWide]);
    
    // Set byte aligned unpacking (needed for 3 byte per pixel bitmaps).
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    NSInteger samplesPerPixel = [bitmap samplesPerPixel];
    
    // Nonplanar, RGB 24 bit bitmap, or RGBA 32 bit bitmap.
    if(![bitmap isPlanar] && (samplesPerPixel == 3 || samplesPerPixel == 4)) {
        
        // Create one OpenGL texture
        glTexImage2D(GL_TEXTURE_2D, 0,
                     GL_RGBA,//samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
                     (GLint)[bitmap pixelsWide],
                     (GLint)[bitmap pixelsHigh],
                     0,
                     GL_RGBA,//samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
                     GL_UNSIGNED_BYTE,
                     [bitmap bitmapData]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    }else{
        [[NSException exceptionWithName:@"ImageFormat" reason:@"Unsupported image format" userInfo:nil] raise];
    }
    CGLUnlockContext([openGLContext CGLContextObj]);
}


/*
 //https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/OpenGL-MacProgGuide/opengl_offscreen/opengl_offscreen.html
//http://www.bit-101.com/blog/?p=1861
+(NSImage*)imageWithGLTexture:(GLuint)glTexture
                  textureType:(GLuint)target
                  textureSize:(NSSize)imageSize
                      context:(NSOpenGLContext*)openGLContext
                      flipped:(BOOL)flipped{
    
    // If we have no size, just exit
    if(imageSize.width == 0){return nil;}
    
    
    CGLLockContext([openGLContext CGLContextObj]);
    [openGLContext makeCurrentContext];
    
    
    
    NSInteger myDataLength = imageSize.width * imageSize.height * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glBindTexture(target, glTexture);

    
    //////////
    //Generate a new FBO. It will contain your texture.
    GLuint offscreen_framebuffer;
    glGenFramebuffers(1, &offscreen_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, offscreen_framebuffer);
    
    //Create the texture
    //glGenTextures(1, &my_texture);
    glBindTexture(target,glTexture);
    //glTexImage2D(target, 0, GL_RGBA,  imageSize.width, imageSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

    
    //Bind the texture to your FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, target, glTexture, 0);
    
    //Test if everything failed
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        printf("failed to make complete framebuffer object %x", status);
    }
   
    
    //Bind the FBO
    glBindFramebuffer(GL_FRAMEBUFFER, offscreen_framebuffer);
    // set the viewport as the FBO won't be the same dimension as the screen
    //glViewport(0, 0, imageSize.width, imageSize.height);
    
    GLubyte* pixels = (GLubyte*) malloc(imageSize.width * imageSize.height * sizeof(GLubyte) * 4);
    glReadPixels(0, 0, imageSize.width, imageSize.height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    
    ///////////
    
    //Bind your main FBO again
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    // set the viewport as the FBO won't be the same dimension as the screen
    //glViewport(0, 0, screen_width, screen_height);
    
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y < imageSize.height; y++)
    {
        for(int x = 0; x < imageSize.width * 4; x++)
        {
            buffer2[(479 - y) * (int)imageSize.width * 4 + x] = buffer[y * 4 * (int)imageSize.width + x];
        }
    }
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * imageSize.width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(imageSize.width, imageSize.height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:NSMakeSize(imageSize.width, imageSize.height)];
    
    
    
    
    CGLUnlockContext([openGLContext CGLContextObj]);
    return image;
}


+(NSImage*)imageWithGLTexture:(GLuint)glTexture
                  textureType:(GLuint)target
                  textureSize:(NSSize)imageSize
                      context:(NSOpenGLContext*)openGLContext
                      flipped:(BOOL)flipped{
    
    // If we have no size, just exit
    if(imageSize.width == 0){return nil;}
    
    
    CGLLockContext([openGLContext CGLContextObj]);
    [openGLContext makeCurrentContext];
    
    NSImage *image=[[NSImage alloc] initWithSize:NSMakeSize(
                                                            imageSize.width,
                                                            imageSize.height)];
    
    
    
    
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc]
                                  initWithBitmapDataPlanes:NULL
                                  pixelsWide:imageSize.width
                                  pixelsHigh:imageSize.height
                                  bitsPerSample:8
                                  samplesPerPixel:4
                                  hasAlpha:YES
                                  isPlanar:NO
                                  colorSpaceName:NSDeviceRGBColorSpace
                                  bytesPerRow:4 * imageSize.width
                                  bitsPerPixel:0
                                  ];
    
    
    glBindTexture(target, glTexture);
    
        glGetTexImage(target,
                  0,
                  GL_RGBA,
                  GL_UNSIGNED_BYTE,
                  [imageRep bitmapData]);
    
    
    [image addRepresentation:imageRep];

  
    
    [image lockFocus];
    [imageRep drawInRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
    [image unlockFocus];
    
 
     //[image addRepresentation:imageRep];
     //[image setFlipped:flipped];
     //[image lockFocusOnRepresentation:imageRep];
     //[image unlockFocus];
 
    
    
    CGLUnlockContext([openGLContext CGLContextObj]);
    return image;
}


/*
 
 http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/
 
- (NSColor *)averageColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)[self TIFFRepresentation], NULL);
    CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), source);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] &gt; 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}
 */



+(NSImage*)imageWithGLTexture:(GLuint)glTexture
                  textureType:(GLuint)target
                  textureSize:(NSSize)imageSize
                      context:(NSOpenGLContext*)openGLContext
                      flipped:(BOOL)flipped{
    
    
    int height = imageSize.height;
    int width = imageSize.width;
    
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc]
                                  initWithBitmapDataPlanes:NULL
                                  pixelsWide:width
                                  pixelsHigh:height
                                  bitsPerSample:8
                                  samplesPerPixel:4
                                  hasAlpha:YES
                                  isPlanar:NO
                                  colorSpaceName:NSDeviceRGBColorSpace
                                  bytesPerRow:4 * width
                                  bitsPerPixel:0
                                  ];
    
    // This call is crucial, to ensure we are working with the correct context
    [openGLContext makeCurrentContext];
    
    GLuint framebuffer, renderbuffer;
    GLenum status;
    // Set the width and height appropriately for your image
    GLuint imageWidth = width, imageHeight = height;
    //Set up a FBO with one renderbuffer attachment
    glGenFramebuffersEXT(1, &framebuffer);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framebuffer);
    glGenRenderbuffersEXT(1, &renderbuffer);
    glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, renderbuffer);
    glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_RGBA8, imageWidth, imageHeight);
    glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                                 GL_RENDERBUFFER_EXT, renderbuffer);
    status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
    if (status != GL_FRAMEBUFFER_COMPLETE_EXT){
        // Handle errors
    }
    //Your code to draw content to the renderbuffer
    //[self drawRect:[self bounds]];
    
    
    //Your code to use the contents
    glReadPixels(0, 0, width, height,
                 GL_RGBA, GL_UNSIGNED_BYTE, [imageRep bitmapData]);
    
    // Make the window the target
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    // Delete the renderbuffer attachment
    glDeleteRenderbuffersEXT(1, &renderbuffer);
    
    NSImage *image=[[NSImage alloc] initWithSize:NSMakeSize(width,height)];
    [image addRepresentation:imageRep];
    [image setFlipped:YES];
    [image lockFocusOnRepresentation:imageRep]; // This will flip the rep.
    [image unlockFocus];
    
    return image;
    
}
@end