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
        _box=box;
        _fixtureType=@"TECLUMEN";
        _address=address;
        _red=0;
        _green=0;
        _blue=0;
        _white=0;
        [self off];
        [_box.lamps setObject:self forKey:[NSString stringWithFormat:@"%i",_address]];
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
    
    
        unsigned char myDmx[DMX_DATA_LENGTH];
    
        // initialize with data to send
        memset(myDmx,0,DMX_DATA_LENGTH);
        
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


        // actual send function called
        BOOL res = [_box.dmxMgr FTDI_SendData:_box.device_handle label:SET_DMX_TX_MODE data:myDmx length:DMX_DATA_LENGTH];
    
        // check response from Send function
        if (res < 0){
            printf("FAILED: Sending DMX to PRO \n");
            [_box.dmxMgr FTDI_ClosePort:_box.device_handle];
        }
    
        [_box.dmxMgr FTDI_PurgeBuffer:_box.device_handle];
    
    
    
}

-(void)setNSColor:(NSColor*)color{
    [self setR:(int)(255*color.redComponent)
             G:(int)(255*color.greenComponent)
             B:(int)(255*color.blueComponent) W:0];
}

-(void)dealloc{
    [_box.lamps removeObjectForKey:[NSString stringWithFormat:@"%i",_address]];
}
@end
