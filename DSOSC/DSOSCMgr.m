//
//  DSOSCMgr.m
//  Watcher
//
//  Created by Andrew on 11/11/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DSOSCMgrProtocol.h"
#import "DSOSCMgr.h"
#import <VVOSC/VVOSC.h>
#import "OSCer.h"
@implementation DSOSCMgr
@synthesize delegate;

-(id)initWithIP:(NSString*)ip port:(NSString*)outPort listenOn:(NSString*)inPort{
    if (self = [super init]){

        // create an OSCManager- set myself up as its delegate
         manager = [[OSCManager alloc] init];
        [manager setDelegate:self];

        // create an input port for receiving OSC data
        if(inPort){
            OSCInPort* inputPort = [manager createNewInputForPort:(int)[inPort integerValue]];
            [self setBindError:!inputPort];
        }

        // create an output so i can send OSC data to myself
        if(ip && outPort){
            _output = [manager createNewOutputToAddress:ip atPort:(int)[outPort integerValue]];
        }



    }
    return self;
}

-(void)shutdown{
    [manager deleteAllInputs];
    [manager deleteAllOutputs];
}


-(void)sendViaOSCAddress:(NSString *)address value:(id)val type:(NSString*)type{
    // make an OSC message
    OSCMessage *newMsg = [OSCMessage createWithAddress:address];

    if([type isEqualToString:@"f"]){
        [newMsg addFloat:[val floatValue]];
    }else if([type isEqualToString:@"i"]){
        [newMsg addFloat:[val integerValue]];
    }else if([type isEqualToString:@"b"]){
        [newMsg addBOOL:[val boolValue]];
    }else{
        [newMsg addString:val];
    }

    [_output sendThisMessage:newMsg];
}

-(void)sendViaOSCAddress:(NSString *)address f_val:(float)val{
    OSCMessage *newMsg = [OSCMessage createWithAddress:address];
    [newMsg addFloat:val];
    [_output sendThisMessage:newMsg];
}

// Incoming OSC message callback, pass on to delegate
- (void) receivedOSCMessage:(OSCMessage *)m	{
    _lastMsgRecieved = [NSDate date];
    [delegate receivedOSCMessage:m];
}

-(void)sendViaOSCAddress:(NSString *)address color:(NSColor *)color{
    color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    OSCMessage *newMsg = [OSCMessage createWithAddress:address];
    [newMsg addInt:(int)(color.redComponent*255)];
    [newMsg addInt:(int)(color.greenComponent*255)];
    [newMsg addInt:(int)(color.blueComponent*255)];
    [newMsg addInt:0.0];
    [_output sendThisMessage:newMsg];
}

@end
