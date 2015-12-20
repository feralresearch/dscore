//
//  DSSyphonSource.m
//  Confess
//
//  Created by Andrew on 11/21/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "DSSyphonSource.h"

@implementation DSSyphonSource

- (id)init{
    if (self = [super init]){
         name=@"";
        _hasWarning=NO;
    }
    return self;
}



// Name
-(NSString*)name{return name;}
-(void)setName:(NSString*)newName{
    [self willChangeValueForKey:@"name"];
    [self willChangeValueForKey:@"displayName"];


    name=newName;

    // Update the displayname
    if(_hasWarning){
        _displayName=[NSString stringWithFormat:@"<!> %@",name];
    }else{
        _displayName=name;
    }

    [self didChangeValueForKey:@"displayName"];
    [self didChangeValueForKey:@"name"];

}


-(void) encodeWithCoder: (NSCoder *)coder{
    [coder encodeObject:name forKey:@"name"];
}


- (id)initWithCoder:(NSCoder *)coder{
    if (self = [super init]) {
        name = [coder decodeObjectForKey:@"name"];
    }
    return self;
}

-(NSImage*)sourceIcon{
    return [[_syphonClient serverDescription] objectForKey:SyphonServerDescriptionIconKey];
}



@end
