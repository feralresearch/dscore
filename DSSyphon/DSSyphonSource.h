//
//  DSSyphonSource.h
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Syphon/Syphon.h>

@interface DSSyphonSource : NSObject{
    NSString* name;
    NSImage* frameCapture;
}


// Shared
@property NSString* displayName;
@property NSDate* lastSeen;
@property NSDate* lastFrame;
@property NSImage* preview;

@property BOOL hasWarning;
@property BOOL didCrash;

@property SyphonImage *syphonImage;
@property SyphonClient* syphonClient;
@property NSMutableDictionary* serverDescriptionDictionary;

-(NSString*)name;
-(void)setName:(NSString*)newName;


@end
