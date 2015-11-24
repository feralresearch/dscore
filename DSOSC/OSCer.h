//
//  OSCer.h
//  Watcher
//
//  Created by Andrew on 11/11/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VVOSC/VVOSC.h>

@interface OSCer : NSObject{
    OSCManager* manager;
}

@property OSCOutPort* output;
@property OSCOutPort* input;

-(id)initWithIP:(NSString*)ip port:(NSString*)outPort listenOn:(NSString*)inPort;
-(void)sendViaOSCAddress:(NSString *)address value:(id)val type:(NSString*)type;
-(void)sendViaOSCAddress:(NSString *)address f_val:(float)val;

@end
