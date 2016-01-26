//
//  Layer.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//



@class DSLayerSource;
@class DSLayerTransformation;
@class CALayer;
@class CIFilter;
@interface DSLayer : NSObject{
    BOOL _loop;
    NSMutableArray* filterArray;
}

@property CALayer* caLayer;
@property NSString* name;
@property NSMutableArray* filters;
@property float alpha;     
@property DSLayerTransformation *transformation;
@property (readonly) DSLayerSource *source;

-(id)initWithSyphonSource:(NSString*)syphonName;
-(id)initWithPath:(NSString*)path;
-(id)initWithPlaceholder;
-(NSString*)sourceType;

-(BOOL)loop;
-(void)setLoop:(BOOL)loop;

-(NSMutableArray*)filterArray;
-(void)setFilterArray:(NSMutableArray *)filterArray;
-(void)addFilter:(CIFilter*)filter;
-(void)removeFilter:(CIFilter*)filter;
-(void)removeAllFilters;
@end
