//
//  Layer.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DSLayerSource;
@class DSLayerTransformation;

@interface DSLayer : NSObject

@property NSMutableArray* filters;
@property float alpha;     
@property DSLayerTransformation *transformation;
@property (readonly) DSLayerSource *source;

-(id)initWithSyphonSource:(NSString*)syphonName;
-(id)initWithPath:(NSString*)path;
-(id)initWithPlaceholder;
-(NSString*)sourceType;

@end
