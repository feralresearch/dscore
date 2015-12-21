//
//  DSSyphonSource.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//


@class SyphonImage;
@class SyphonClient;

@interface DSSyphonSource : NSObject{
    NSString* name;
    NSImage* frameCapture;
}


// Shared
@property NSString* displayName;
@property NSDate* lastSeen;
@property NSDate* lastFrame;


@property BOOL hasWarning;
@property BOOL didCrash;

@property SyphonImage *syphonImage;
@property SyphonClient* syphonClient;
@property NSMutableDictionary* serverDescriptionDictionary;

-(NSString*)name;
-(void)setName:(NSString*)newName;
-(NSImage*)sourceIcon;

@end
