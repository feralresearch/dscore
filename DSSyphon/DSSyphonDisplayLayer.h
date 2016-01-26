//
//  DSSyphonDisplayLayer.h
//  DSCore
//
//  Created by Andrew on 12/30/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
@class DSLayerSourceSyphon;
@interface DSSyphonDisplayLayer : CAOpenGLLayer{
    CGImageRef currentCGImage;
    GLuint texture;
    CVPixelBufferRef pixelBuffer;
}

- (id) initWithSource:(DSLayerSourceSyphon*)source;
@property (readonly)  DSLayerSourceSyphon* source;
@property (readonly) CGLContextObj openGlContext;


@end
