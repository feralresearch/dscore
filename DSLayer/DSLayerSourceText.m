//
//  DSLayerSourceText.m
//  DSCore
//
//  Created by Andrew on 1/29/16.
//  Copyright © 2016 Digital Scenographic. All rights reserved.
//

#import "DSLayerSourceText.h"
#import "DSLayer.h"

@implementation DSLayerSourceText

- (id)initWithString:(NSString*)text parentLayer:(DSLayer*)parentLayer{
    if (self = [super init]){
        self.parentLayer=parentLayer;
        
        
        
        [parentLayer setCaLayer:[self layerWithString:text
                                                 font:@"HelfaSemiBold"
                                                 size:20
                                                color:[NSColor whiteColor]]];
        
    }
    return self;
}


-(CATextLayer*)layerWithString:(NSString*)content font:(NSString*)font size:(float)fontSize color:(NSColor*)fontColor{
    
    CTFontRef fontFace = CTFontCreateWithName((__bridge CFStringRef)(font), fontSize, NULL);
    attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:(__bridge id)fontFace forKey:(NSString*)kCTFontAttributeName];
    [attributes setObject:(__bridge id)[fontColor CGColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    attrStr = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    
    textLayer = [CATextLayer layer];
    textLayer.backgroundColor = [NSColor clearColor].CGColor;
    textLayer.frame = CGRectMake(20, 20, 200, 100);
    textLayer.string = attrStr;
    
    return textLayer;

}

-(void)setContent:(NSString*)content{
    attrStr = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    
    [(CATextLayer*)self.parentLayer.caLayer setString:attrStr];
}
-(NSString*)content{
    return  [(CATextLayer*)self.parentLayer.caLayer string];
}
@end
