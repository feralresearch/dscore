//
//  DSDMXDevice.h
//  OSCLight
//
//  Created by Andrew on 12/18/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Ftd2xx.h"
@class DSDMXManager;

@interface DSDMXBox : NSObject{}

@property int deviceID;
@property FT_HANDLE device_handle;
@property DSDMXManager* dmxMgr;
@property NSMutableDictionary* lamps;
@property int latencyTimer;
@property NSString* serialNumber;
@property NSString* firmwareVersion;
@property int breakTimeInMicroseconds;
@property int mabTimeInMicroseconds;
@property int refreshRatePacketPerSeconds;

- (id)initWithMgr:(DSDMXManager*)mgr;





@end
