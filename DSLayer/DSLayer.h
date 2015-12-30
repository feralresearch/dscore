//
//  Layer.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//



@class DSLayerSource;
@class DSLayerTransformation;

@interface DSLayer : NSObject{
    BOOL _loop;
}

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

@end
