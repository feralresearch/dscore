//
//  OSCerProtocol.h
//  DSCore
//
//  Created by Andrew on 12/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//
@class OSCMessage;
@protocol OSCerDelegate <NSObject>
- (void) receivedOSCMessage:(OSCMessage *)m;
@end

