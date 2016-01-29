//
//  DSLayerSourceCamera.h
//  DSCore
//
//  Created by Andrew on 1/29/16.
//  Copyright © 2016 Digital Scenographic. All rights reserved.
//

#import <DSCore/DSCore.h>
@class AVCaptureDevice;
@interface DSLayerSourceCamera : DSLayerSource{
    DSCamera *camera;
}
@property AVCaptureVideoPreviewLayer *previewLayer;
@property AVSampleBufferDisplayLayer *displayLayer;

- (id)initWithCameraID:(NSString*)camid;

-(NSImage*) icon;

@end
