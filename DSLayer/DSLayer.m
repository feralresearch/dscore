//
//  Layer.m
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSLayerSource.h"
#import "DSLayerTransformation.h"
#import "DSLayer.h"
#import "DSLayerTransformation.h"
#import "DSLayerSourceSyphon.h"
#import "DSLayerSourceImage.h"
#import "DSLayerSourceVideo.h"

@implementation DSLayer

- (id)initWithSyphonSource:(NSString*)syphonName{
    if (self = [super init]){
        _filters = [[NSMutableArray alloc] init];
        _transformation = [[DSLayerTransformation alloc] init];
        _alpha=1.0;
        _source = [[DSLayerSourceSyphon alloc] initWithServerDesc:syphonName];
        _name = @"UNTITLED";
    }
    return self;
}

- (id)initWithPath:(NSString *)path{
    if (self = [super init]){
        _filters = [[NSMutableArray alloc] init];
        _transformation = [[DSLayerTransformation alloc] init];
        _alpha=1.0;

        // Determine if path is an image or a video
        if(path.length != 0){
            CFStringRef fileExtension = (__bridge CFStringRef) [path pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
            
            if (UTTypeConformsTo(fileUTI, kUTTypeImage)){
                _source = [[DSLayerSourceImage alloc] initWithPath:path];
            }else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)){
                _source = [[DSLayerSourceVideo alloc] initWithPath:path];
            }
            
            CFRelease(fileUTI);
        }
        
        
    }
    return self;
}

- (id)initWithPlaceholder{
    if (self = [super init]){
        _filters = nil;
        _transformation = nil;
        _alpha=0.0;
        
        // Determine if path is an image or a video
        _source = nil;
    }
    return self;
}

-(NSString*)sourceType{
    if([_source isKindOfClass:[DSLayerSourceImage class]]){
        return @"image";

    }else if([_source isKindOfClass:[DSLayerSourceSyphon class]]){
        return @"syphon";

    }else if([_source isKindOfClass:[DSLayerSourceVideo class]]){
        return @"video";

    }else{
        return @"unknown";
    }
}

-(BOOL)loop{
    if([_source isKindOfClass:[DSLayerSourceVideo class]]){
        DSLayerSourceVideo* vSource=(DSLayerSourceVideo*)_source;
        return vSource.loop;
    }else{
        NSLog(@"WARNING: Layer does not support looping");
    }
    return NO;
}
-(void)setLoop:(BOOL)loop{
    if([_source isKindOfClass:[DSLayerSourceVideo class]]){
        DSLayerSourceVideo* vSource=(DSLayerSourceVideo*)_source;
        [vSource setLoop:loop];
    }else{
        NSLog(@"WARNING: Layer does not support looping");
    }
}

-(NSMutableArray*)filterArray{
    if(!filterArray){
        filterArray=[[NSMutableArray alloc] init];
    }
    return filterArray;
}
-(void)setFilterArray:(NSMutableArray *)newFilterArray{
    [self willChangeValueForKey:@"filterArray"];
    filterArray=newFilterArray;
    [_caLayer setFilters:filterArray];
    [self didChangeValueForKey:@"filterArray"];
}
-(void)removeAllFilters{
    [self setFilterArray:[[NSMutableArray alloc] init]];
}

-(void)addFilter:(CIFilter*)filter{
    NSMutableArray* newFilterArray = self.filterArray;
    [filterArray addObject:filter];
    [self setFilterArray:newFilterArray];
}
-(void)removeFilter:(CIFilter*)filter{
    NSMutableArray* newFilterArray = self.filterArray;
    [filterArray removeObject:filter];
    [self setFilterArray:newFilterArray];
}

@end
