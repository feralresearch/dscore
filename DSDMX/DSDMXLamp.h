//
//  DSDMXLamp.h
//  OSCLight
//
//  Created by Andrew on 12/18/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DSDMXBox;

@interface DSDMXLamp : NSObject{}

@property DSDMXBox *box;
@property NSString *fixtureType;
@property int address;
@property int red;
@property int green;
@property int blue;
@property int white;

-(id)initChannel:(int)address onBox:(DSDMXBox*)box;
-(void)setNSColor:(NSColor*)color;
-(void)setR:(int)red G:(int)green B:(int)blue W:(int)white;
-(void)off;

@end
