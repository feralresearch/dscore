
//
//  SourceCameras.m
//  SyMix
//
//  Created by Andrew Sempere on 4/23/14.
//  Copyright (c) 2014 Feral Research. All rights reserved.
//
#import "CWLSynthesizeSingleton.h"
#import "DSCameraManager.h"

@implementation DSCameraManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(DSCameraManager)

- (id)init{
    if (self = [super init]){
        [self refreshAvailableDevices];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cameraAdded:)
                                                     name:AVCaptureDeviceWasConnectedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cameraRemoved:)
                                                     name:AVCaptureDeviceWasDisconnectedNotification
                                                   object:nil];
    }
    return self;
}


// Called by init
-(void)refreshAvailableDevices{

    _availableDeviceByID = [[NSMutableDictionary alloc] init];
    NSArray* deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *device in deviceArray){
        if ([device.localizedName rangeOfString:@"CamTwist"].location == NSNotFound) {
            [_availableDeviceByID setObject:device forKey:device.uniqueID];
        }
    }
    NSLog(@"\n\n");
}

-(void)cameraAdded:(NSNotification *)notification{
    [self refreshAvailableDevices];

    if([_delegate respondsToSelector:@selector(cameraAdded:)]) {
        [_delegate cameraAdded:notification];
    }
}

-(void)cameraRemoved:(NSNotification *)notification{
    [self refreshAvailableDevices];
    if([_delegate respondsToSelector:@selector(cameraRemoved:)]) {
        [_delegate cameraRemoved:notification];
    }

}



@end
