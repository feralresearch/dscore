//
//  OSCer.h
//  Watcher
//
//  Created by Andrew on 11/11/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//


@class OSCMessage;
@class OSCOutPort;
@class OSCManager;

@class AppDelegate;
@class NSColor;

#include "DSOSCMgrProtocol.h"

@interface DSOSCMgr : NSObject{
    OSCManager* manager;
    AppDelegate* thisAppDelegate;
}

@property (nonatomic, weak) id <DSOSCMgrDelegate> delegate; //define MyClassDelegate as delegate

@property (readonly)  NSDate *lastMsgRecieved;
@property OSCOutPort* output;
@property OSCOutPort* input;
@property BOOL bindError;


-(id)initWithIP:(NSString*)ip port:(NSString*)port listenOn:(NSString*)port;
-(void)sendViaOSCAddress:(NSString *)address value:(id)val type:(NSString*)type;
-(void)sendViaOSCAddress:(NSString *)address color:(NSColor*)color;
-(void)sendViaOSCAddress:(NSString *)address f_val:(float)val;
-(void)shutdown;

@end


