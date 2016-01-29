//
//  DSLayerSourceCamera.m
//  DSCore
//
//  Created by Andrew on 1/29/16.
//  Copyright © 2016 Digital Scenographic. All rights reserved.
//

#import "DSLayerSourceCamera.h"

@implementation DSLayerSourceCamera


- (id)initWithCameraID:(NSString*)camid{
    if (self = [super init]){
        camera =[[DSCamera alloc] initWithCameraID:camid delegate:self];
        
        AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:camera.device error:nil];
        [captureSession addInput:videoInput];
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        [captureSession startRunning];
        NSLog(@"NOTE: CAImageQueueSetOwner() warning is an apple bug, ignore it.");
        
    }
    return self;
}

-(NSImage*) icon{
    return [NSImage imageNamed:NSImageNameComputer];
}
@end


