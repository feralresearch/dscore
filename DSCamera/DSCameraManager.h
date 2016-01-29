//
//  SourceCameras.h
//  SyMix
//
//  Created by Andrew Sempere on 4/23/14.
//  Copyright (c) 2014 Feral Research. All rights reserved.
//
#import "CWLSynthesizeSingleton.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "DSCameraView.h"
#import "DSCamera.h"

@interface DSCameraManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>{}

CWL_DECLARE_SINGLETON_FOR_CLASS(DSCameraManager)

-(void)refreshAvailableDevices;
@property NSMutableDictionary* availableDeviceByID;
@property id delegate;

@end


@interface NSObject(DSCameraManagerDelegate)
    -(void)cameraAdded:(NSNotification *)notification;
    -(void)cameraRemoved:(NSNotification *)notification;
@end
