//
//  DSSyphonMgr.m
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "CWLSynthesizeSingleton.h"
#import <Syphon/Syphon.h>
#import "DSSyphonSource.h"
#import "DSSyphonMgr.h"

@implementation DSSyphonMgr

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(DSSyphonMgr)

- (id)init{
    if (self = [super init]){
        _syphonSourcesByDesc=[[NSMutableDictionary alloc] init];
        [self refreshSyphonSources];

        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:.5
                                         target:self
                                       selector:@selector(refreshSyphonSources)
                                       userInfo:nil
                                        repeats:YES];

        [self setSourceTimeout:2.0];

    }
    return self;
}

// Update sources
-(void)refreshSyphonSources{

    BOOL wasChange=NO;

    // Rebuild
    for(NSDictionary* thisSyphonServer in [[SyphonServerDirectory sharedDirectory] servers]){


        // Make description string
        NSString *serverDescription = [NSString stringWithFormat:@"%@ %@",
                                       [thisSyphonServer valueForKey:@"SyphonServerDescriptionAppNameKey"],
                                       [thisSyphonServer valueForKey:@"SyphonServerDescriptionNameKey"]];
        serverDescription = [serverDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];


        // Do we know about this source?
        DSSyphonSource* thisSource=[_syphonSourcesByDesc objectForKey:serverDescription];

        // Add brand new source
        if(!thisSource){
            thisSource = [[DSSyphonSource alloc] init];
            thisSource.name=serverDescription;
            thisSource.hasWarning=YES;
            [_syphonSourcesByDesc setObject:thisSource forKey:serverDescription];
            wasChange=YES;
        }

        // If this source has a warning, try rebuilding the client
        if(thisSource.hasWarning){
            thisSource.syphonClient=nil;
            thisSource.syphonClient= [[SyphonClient alloc]
                                      initWithServerDescription:thisSyphonServer
                                      options:nil
                                      newFrameHandler:^(SyphonClient *client) {[self newFrameAvailableFor:thisSource];}];
            thisSource.hasWarning=FALSE;
        }

        // Last time we heard about this source (which is not the last time we saw a frame - that's handled in callback)
        thisSource.lastSeen=[NSDate date];

        // Update dictionaries
        [_syphonSourcesByDesc setValue:thisSource forKey:serverDescription];
        [thisSource.serverDescriptionDictionary setValue:serverDescription forKey:@"syphonServerDescription"];
    }


    // Flag/Remove missing sources
    for(NSString* serverDescription in _syphonSourcesByDesc){
        DSSyphonSource* thisSource=[_syphonSourcesByDesc objectForKey:serverDescription];

        // If the source crashed (not exit, but crash) we get "updates" but not new frames
        if(!thisSource.hasWarning &&
            ([[NSDate date] timeIntervalSinceDate:thisSource.lastFrame] > _sourceTimeout ||
             [[NSDate date] timeIntervalSinceDate:thisSource.lastSeen] > _sourceTimeout)){
            //NSLog(@"WARNING: %@ for timeout %f - %f",serverDescription,[[NSDate date] timeIntervalSinceDate:thisSource.lastFrame],[[NSDate date] timeIntervalSinceDate:thisSource.lastSeen]);
            thisSource.hasWarning=YES;
            wasChange=YES;
        }
    }


    if(wasChange){
        [_delegate syphonSourceChange];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"SyphonSourceChange"
         object:self];
    }
    _syphonServerCount = (int)[[[SyphonServerDirectory sharedDirectory] servers] count];

}

// Log last time we got a new frame
-(void)newFrameAvailableFor:(DSSyphonSource*)thisSource{
    thisSource.lastFrame=[NSDate date];
}
@end
