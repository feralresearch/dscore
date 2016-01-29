//
// DSCamera.h
//  Watcher
//
//  Created by Andrew on 10/27/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "DSCameraManager.h"

@interface DSCamera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>{
    id delegate;
    AVCaptureSession *session;
    AVCaptureVideoDataOutput *output;
    dispatch_queue_t queue;
}

@property (readonly) NSString* cameraID;
@property (readonly) NSString* userID;
@property (readonly) AVCaptureDevice *device;

- (id)initWithCameraID:(NSString*)cameraID  delegate:(id)myDelegate;
- (void)shutdown;
- (void)setDelegate:(id)delegate;
@end

@interface NSObject(MyDelegateMethods)
    //-(void)newFrame:(NSImage*)frame forCameraID:(NSString*)cameraID;
    -(void)newBuffer:(CMSampleBufferRef)sampleBuffer forCameraID:(NSString*)cameraID;
@end
