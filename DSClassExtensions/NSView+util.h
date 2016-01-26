//
//  NSView+util.h
//  DSCore
//
//  Created by Andrew on 12/31/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface NSView (util) {}
-(NSImage*) screenCacheImageForView;
-(CGImageRef)screenshotAsCGImageRef;
@end
