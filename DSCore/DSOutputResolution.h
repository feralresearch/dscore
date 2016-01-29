//
//  DSOutputResolution.h
//  FRCore
//
//  Created by Andrew Sempere on 3/30/2014
//  Copyright (c) 2014 Andrew Sempere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSOutputResolution : NSObject
@property NSString* name;
@property NSString* ratio;
@property NSSize size;
@property float multiplier;

+ (DSOutputResolution*)newResolution:(NSSize)size;

@end
