//
//  DSLayerSourceText.h
//  DSCore
//
//  Created by Andrew on 1/29/16.
//  Copyright © 2016 Digital Scenographic. All rights reserved.
//

#import <DSCore/DSCore.h>

@interface DSLayerSourceText : DSLayerSource{
    NSMutableDictionary *attributes;
    NSAttributedString *attrStr;
    CATextLayer *textLayer;
}
- (id)initWithString:(NSString*)text parentLayer:(DSLayer*)parentLayer;
-(void)setContent:(NSString*)content;
-(NSString*)content;
@end
