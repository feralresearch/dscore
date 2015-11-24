//
//  LayerSourceVideo.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "DSLayerSource.h"

@interface DSLayerSourceVideo : DSLayerSource

@property NSString* path;
- (id)initWithPath:(NSString*)path;
@end
