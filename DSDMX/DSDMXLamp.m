//
//  DSDMXLamp.m
//  OSCLight
//
//  Created by Andrew on 12/18/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "DSDMXLamp.h"
#import "DSDMXManager.h"
#import "DSDMXBox.h"

@implementation DSDMXLamp

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initChannel:onBox:"
                                 userInfo:nil];
    return nil;
}

- (id)initChannel:(int)address onBox:(DSDMXBox*)box{
    if (self = [super init]){
        _autoWhite=NO;
        _box=box;
        _fixtureType=@"TECLUMEN";
        _address=address;
        _red=0;
        _green=0;
        _blue=0;
        _white=0;
        [_box.lamps setObject:self forKey:[NSString stringWithFormat:@"%i",_address]];
        
        [self off];
        
    }
    return self;
}

-(void)off{
    [self setR:0 G:0 B:0 W:0];
}


-(void)setR:(int)red G:(int)green B:(int)blue W:(int)white{
    
    
    
    // Keep things 0-255
    red=red<0?0:red;
    red=red>255?255:red;
    green=green<0?0:green;
    green=green>255?255:green;
    blue=blue<0?0:blue;
    blue=blue>255?255:blue;
    white=white<0?0:white;
    white=white>255?255:white;
    

    //NSLog(@"Set #%i, (%i,%i,%i | %i)",_address,red,green,blue,white);
    
    
    
        // initialize with data to send
        //memset(myDmx,0,DMX_DATA_LENGTH);
        unsigned char* myDmx = (unsigned char*)[ [[DSDMXManager sharedInstance] DMXData] bytes];
    
        // Start Code = 0
        // Mode RGBW4
        myDmx[0] = 0;

        int r_channel = _address;
        int g_channel = _address+1;
        int b_channel = _address+2;
        int w_channel = _address+3;

        myDmx[r_channel]=red;
        myDmx[g_channel]=green;
        myDmx[b_channel]=blue;
        myDmx[w_channel]=white;



        
        [self setRed:red];
        [self setGreen:green];
        [self setBlue:blue];
        [self setWhite:white];
     //   }
        [[DSDMXManager sharedInstance] setUpdateNeeded:YES];

    
    
}

struct colorRGBW {
    unsigned int   red;
    unsigned int   green;
    unsigned int   blue;
    unsigned int   white;
};

-(void)setColor:(NSColor*)color{
    color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

    struct colorRGBW rgbw = {(255*color.redComponent),
                            (255*color.greenComponent),
                            (255*color.blueComponent),
                            _white};

    if(_autoWhite){
        rgbw = [self toRGBWFromR:(int)(255*color.redComponent)
                               G:(int)(255*color.greenComponent)
                               B:(int)(255*color.blueComponent)];
    }
    
    [self setR:rgbw.red
             G:rgbw.green
             B:rgbw.blue
             W:rgbw.white];
}

-(void)dealloc{
    [_box.lamps removeObjectForKey:[NSString stringWithFormat:@"%i",_address]];
}


/* These come from http://codewelt.com/rgbw */


// The saturation is the colorfulness of a color relative to its own brightness.
-(float)saturation:(struct colorRGBW)rgbw{
    // Find the smallest of all three parameters.
    float low = MIN(rgbw.red, MIN(rgbw.green, rgbw.blue));
    // Find the highest of all three parameters.
    float high = MAX(rgbw.red, MAX(rgbw.green, rgbw.blue));
    // The difference between the last two variables
    // divided by the highest is the saturation.
    float saturation = round(100 * ((high - low) / high));
    return saturation;
}

// Returns the value of White
-(float)getWhite:(struct colorRGBW)rgbw{
    float whiteVal = (255 - [self saturation:rgbw]) / 255 * (rgbw.red + rgbw.green + rgbw.blue) / 3;
    return whiteVal;
}

// Use this function for too bright emitters. It corrects the highest possible value.
-(float) getWhite:(struct colorRGBW)rgbw redMax:(int)redMax greenMax:(int)greenMax blueMax:(int)blueMax{
    // Set the maximum value for all colors.
    rgbw.red = (float)rgbw.red / 255.0 * (float)redMax;
    rgbw.green = (float)rgbw.green / 255.0 * (float)greenMax;
    rgbw.blue = (float)rgbw.blue / 255.0 * (float)blueMax;
    float whiteVal =(255 - [self saturation:rgbw]) / 255 * (rgbw.red + rgbw.green + rgbw.blue) / 3;
    return whiteVal;
}

// RGB->RGBW
-(struct colorRGBW)toRGBWFromR:(unsigned int)red G:(unsigned int)green B:(unsigned int)blue{
    unsigned int white = 0;
    struct colorRGBW rgbw = {red, green, blue, white};
    rgbw.white = (int)[self getWhite:rgbw];
    return rgbw;
}

// Example function with color correction.
-(struct colorRGBW)toRGBWFromR:(unsigned int)red
                             G:(unsigned int)green
                             B:(unsigned int)blue
                          maxR:(unsigned int)redMax
                          maxG:(unsigned int)greenMax
                          maxB:(unsigned int)blueMax{
    unsigned int white = 0;
    struct colorRGBW rgbw = {red, green, blue, white};
    rgbw.white = (int)[self getWhite:rgbw redMax:redMax greenMax:greenMax blueMax:blueMax];
    return rgbw;
}



@end
