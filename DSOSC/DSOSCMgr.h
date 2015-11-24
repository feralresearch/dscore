//
//  OSCer.h
//  Watcher
//
//  Created by Andrew on 11/11/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VVOSC/VVOSC.h>
@class AppDelegate;

@protocol OSCerDelegate <NSObject>
    - (void) receivedOSCMessage:(OSCMessage *)m;
@end


@interface DSOSCMgr : NSObject{
    OSCManager* manager;
    AppDelegate* thisAppDelegate;
    BOOL activityDetected;
}

@property (nonatomic, weak) id <OSCerDelegate> delegate; //define MyClassDelegate as delegate

@property (readonly)  NSDate *lastMsgRecieved;
@property OSCOutPort* output;
@property OSCOutPort* input;

-(id)initWithIP:(NSString*)ip port:(NSString*)port listenOn:(NSString*)port;
-(void)sendViaOSCAddress:(NSString *)address value:(id)val type:(NSString*)type;
-(void)sendViaOSCAddress:(NSString *)address f_val:(float)val;


@end


