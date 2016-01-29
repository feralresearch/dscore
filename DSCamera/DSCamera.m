//
// DSCamera.m
//  Watcher
//
//  Created by Andrew on 10/27/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "DSCamera.h"


@implementation DSCamera



- (id)initWithCameraID:(NSString*)initCameraID  delegate:(id)myDelegate{
    if (self = [super init]){
        [self initializeCameraWithID:initCameraID];
        _cameraID=initCameraID;
        delegate=myDelegate;
    }
    return self;
}

- (void)shutdown{
    [session stopRunning];
}

- (void)setDelegate:(id)newDelegate{
    delegate=newDelegate;
    queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:delegate queue:queue];
}


// AVCaptureVideoDataOutputSampleBufferDelegate
-(void)initializeCameraWithID:(NSString*)cameraID{
    NSError *error = nil;

    // Create the session
    session = [[AVCaptureSession alloc] init];

    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
   //session.sessionPreset = AVCaptureSessionPreset640x480;

    // Find a suitable AVCaptureDevice
    _device = [AVCaptureDevice deviceWithUniqueID:cameraID];

    if(!_device){
        NSLog(@"WARNING: Not initializing camera ID %@, camera disconnected?",cameraID);
    }else{

        // Create a device input with the device and add it to the session.
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_device
                                                                            error:&error];
        if (!input){NSLog(@"PANIC: no media input");}
        [session addInput:input];

        // Create a VideoDataOutput and add it to the session
        output = [[AVCaptureVideoDataOutput alloc] init];
        [session addOutput:output];

        // Configure your output.
        queue = dispatch_queue_create("myQueue", NULL);
        [output setSampleBufferDelegate:delegate queue:queue];

        // Specify the pixel format
        output.videoSettings =
        [NSDictionary dictionaryWithObject:
         [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                    forKey:(id)kCVPixelBufferPixelFormatTypeKey];

        

        // Start the session running to start the flow of data
        [session startRunning];
    }
}



- (NSImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);

    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // Create an image object from the Quartz image
    NSImage *image = [[NSImage alloc] initWithCGImage:quartzImage size:NSMakeSize(width, height)];

    // Release the Quartz image
    CGImageRelease(quartzImage);

    return (image);
}


@end
