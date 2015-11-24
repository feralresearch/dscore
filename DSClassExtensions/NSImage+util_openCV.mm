//
//  NSImage+util_openCV.mm
// Thx: http://stackoverflow.com/questions/8563356/nsimage-to-cvmat-and-vice-versa
#include <opencv2/opencv.hpp>
#import <AppKit/AppKit.h>
#import <AVFoundation/AVFoundation.h>
#import "NSImage+util_openCV.h"


// This is a "category" style extension to the NSImage class
@implementation NSImage (NSImage_util_openCV)

- (id)initWithCVMat:(const cv::Mat&)cvMat{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1){
        colorSpace = CGColorSpaceCreateDeviceGray();
    }else{
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}
-(CGImageRef)CGImage{
    CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                   [self size].width,
                                                   [self size].height,
                                                   8 /*bitsPerComponent*/,
                                                   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                   [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                   kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
    [self drawInRect:NSMakeRect(0,0, [self size].width, [self size].height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapCtx);
    CGContextRelease(bitmapCtx);
    
    // Potential leak from analyzer, no way around this one...
    return cgImage;
    
    
}
-(cv::Mat)CVMat{
    CGImageRef imageRef = [self CGImage];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    return cvMat;
}
-(cv::Mat)CVGrayscaleMat{
    CGImageRef imageRef = [self CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    cv::Mat cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return cvMat;
}

+(NSImage *) imageWithCVMat:(const cv::Mat&)cvMat{

    return [[NSImage alloc] initWithCVMat:cvMat];
}
+(NSImage *) imageFromPixels:(unsigned char*)pixels ofSize:(NSSize) size{
    
    NSImage * ns_Image = [[NSImage alloc] initWithSize:size];
    
    
    // Config
    int bitsPerSample=8;
    int samplesPerPixel=4; //3 for rgb 1 for grey
    //pixelsWide * bitsPerSample * samplesPerPixel / 8
    int bytesPerRow =  size.width * bitsPerSample * samplesPerPixel / 8;
    //bitsPerSample * samplesPerPixel
    int bitsPerPixel = bitsPerSample * samplesPerPixel;
    
    // Actually build and render the image
    NSBitmapImageRep *imgRep =
    [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&pixels
                                            pixelsWide:size.width
                                            pixelsHigh:size.height
                                         bitsPerSample:bitsPerSample
                                       samplesPerPixel:samplesPerPixel
                                              hasAlpha:TRUE
                                              isPlanar:FALSE
                                        colorSpaceName:NSDeviceRGBColorSpace
                                          bitmapFormat:0
                                           bytesPerRow:bytesPerRow
                                          bitsPerPixel:bitsPerPixel];
    
    [ns_Image addRepresentation:imgRep];
    return ns_Image;
}
+(IplImage *)iplImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    IplImage *iplimage = 0;

    if (sampleBuffer) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);

        // get information of the image in the buffer
        uint8_t *bufferBaseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        size_t bufferWidth = CVPixelBufferGetWidth(imageBuffer);
        size_t bufferHeight = CVPixelBufferGetHeight(imageBuffer);

        // create IplImage
        if (bufferBaseAddress) {
            iplimage = cvCreateImage(cvSize((int)bufferWidth, (int)bufferHeight), IPL_DEPTH_8U, 4);

            //iplimage->imageData = (char*)bufferBaseAddress;
            memcpy(iplimage->imageData, (char*)bufferBaseAddress, iplimage->imageSize);
        }

        // release memory
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    else
        NSLog(@"WARNING: Invalid sampleBuffer");

    return iplimage;


}

-(cv::Mat)CVMatFromNSImage:(NSImage*)img{
    CGImageRef imageRef = [self CGImageFromNSImage:img];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGFloat cols = img.size.width;
    CGFloat rows = img.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    return cvMat;
}

-(CGImageRef)CGImageFromNSImage:(NSImage*)img{
    CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                   [img size].width,
                                                   [img size].height,
                                                   8 /*bitsPerComponent*/,
                                                   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                   [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                   kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
    [img drawInRect:NSMakeRect(0,0, [img size].width, [img size].height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];

    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapCtx);
    CGContextRelease(bitmapCtx);

    // Potential leak from analyzer, no way around this one...
    return cgImage;
    
    
}

@end