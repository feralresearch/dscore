//
//  LayerSourceVideo.m
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "DSLayerSourceVideo.h"

@implementation DSLayerSourceVideo

- (id)initWithPath:(NSString*)path{
    if (self = [super init]){
        NSLog(@"Init video with path: %@",path);
    }
    return self;
}


@end
