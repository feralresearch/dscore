//
//  DSSyphonMgr.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "CWLSynthesizeSingleton.h"

@protocol SyphonDelegate <NSObject>
    - (void) syphonSourceChange;
@end

@interface DSSyphonMgr : NSObject{
    NSTimer* refreshTimer;
}

CWL_DECLARE_SINGLETON_FOR_CLASS(DSSyphonMgr)

@property (nonatomic, weak) id <SyphonDelegate> delegate;
@property (readonly) int syphonServerCount;
@property NSMutableDictionary* syphonSourcesByDesc;
@property float sourceTimeout;

@end
