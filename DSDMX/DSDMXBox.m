//
//  DSDMXDevice.m
//  OSCLight
//
//  Created by Andrew on 12/18/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "DSDMXBox.h"
#import "DSDMXManager.h"
@implementation DSDMXBox
- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initWithMgr:"
                                 userInfo:nil];
    return nil;
}

- (id)initWithMgr:(DSDMXManager*)mgr{
    if (self = [super init]){
        _dmxMgr =mgr;
        _lamps = [[NSMutableDictionary alloc] init];
        _serialNumber = @"Unknown";
        _firmwareVersion = @"";
        _breakTimeInMicroseconds=0;
        _mabTimeInMicroseconds=0;
        _refreshRatePacketPerSeconds=0;
    }
    return self;
}


@end
