//
//  Syphoner.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//


// FIXME: should be made into singleton


@protocol SyphonDelegate <NSObject>
    - (void) syphonSourceChange;
@end

@interface DSSyphonMgr : NSObject{
    NSTimer* refreshTimer;
}
+(id)sharedInstance;

@property (nonatomic, weak) id <SyphonDelegate> delegate;
@property (readonly) int syphonServerCount;
@property NSMutableDictionary* syphonSourcesByDesc;
@property float sourceTimeout;

@end
