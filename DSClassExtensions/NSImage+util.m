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
    if (![inputImage isFlipped]) {
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
    }
    
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
    [image setFlipped:flipped];
    [image lockFocusOnRepresentation:imageRep];
    [image unlockFocus];
    
    
    
    CGLUnlockContext([openGLContext CGLContextObj]);
    return image;
}
@end