//
//  LayerTransformation.m
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "DSLayerTransformation.h"

@implementation DSLayerTransformation

- (id)init{
    if (self = [super init]){
        _rotationAngle=0;
        _scaleX=0;
        _scaleY=0;
        _translateX=0;
        _translateY=0;
    }
    return self;
}

@end
