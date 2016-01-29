//
//  DSOutputResolution.m
//  FRCore
//
//  Created by Andrew Sempere on 3/30/2014
//  Copyright (c) 2014 Andrew Sempere. All rights reserved.
//

#import "DSOutputResolution.h"

@implementation DSOutputResolution

- (id)init{
    if (self = [super init]){}
    return self;
}


// Decode for loading
- (id)initWithCoder:(NSCoder *)coder;{
    
    if (self = [super init]) {
        _name = [coder decodeObjectForKey:@"name"];
        _ratio = [coder decodeObjectForKey:@"ratio"];
        _size = [coder decodeSizeForKey:@"size"];
    }
    
    return self;
    
}

// Encode for saving
- (void) encodeWithCoder: (NSCoder *)coder{
    
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_ratio forKey:@"ratio"];
    [coder encodeSize:_size forKey:@"size"];
    
}

// Create a new resolution
+ (DSOutputResolution*)newResolution:(NSSize)size{
    DSOutputResolution* resolutionObject=[[DSOutputResolution alloc] init];
    resolutionObject.size=size;
    resolutionObject.ratio=[NSString stringWithFormat:@"%0.1f",size.width/size.height];
    if([resolutionObject.ratio isEqualToString:@"1.3"]){
        resolutionObject.ratio=@"4:3";
    }else if([resolutionObject.ratio isEqualToString:@"1.6"]){
        resolutionObject.ratio=@"16:9";
    }
    resolutionObject.multiplier=(float)size.height/size.width;
    resolutionObject.name=[NSString stringWithFormat:@"%i x %i (%@)", (int)size.width, (int)size.height,resolutionObject.ratio];
    return resolutionObject;
}

@end
