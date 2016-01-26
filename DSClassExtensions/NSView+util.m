//
//  NSView+util.m
//  DSCore
//
//  Created by Andrew on 12/31/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import "NSView+util.h"

@implementation NSView (util)



// Screenshot entire screen and then cut down (this will grab everything)
//http://stackoverflow.com/questions/11948241/cocoa-how-to-render-view-to-image
-(NSImage*) screenCacheImageForView{
    NSRect originRect = [self convertRect:[self bounds] toView:[self.window contentView]];
    
    NSArray *screens = [NSScreen screens];
    NSScreen *primaryScreen = [screens objectAtIndex:0];
    
    NSRect rect = originRect;
    rect.origin.y = 0;
    rect.origin.x += [self window].frame.origin.x;
    rect.origin.y = primaryScreen.frame.size.height - [self window].frame.origin.y - originRect.origin.y - originRect.size.height;
    
    CGImageRef cgimg = CGWindowListCreateImage(rect,
                                               kCGWindowListOptionIncludingWindow,
                                               (CGWindowID)[[self window] windowNumber],
                                               kCGWindowImageDefault);
    return [[NSImage alloc] initWithCGImage:cgimg size:[self bounds].size];
}



/**
 * Returns an offscreen view containing all visual elements of this view for printing,
 * including CALayer content. Useful only for views that are layer-backed.
 
 
 http://stackoverflow.com/questions/13760187/capturing-an-offline-nsview-to-an-nsimage
 
 */
- (CGImageRef)screenshotAsCGImageRef{
    NSRect bounds = self.bounds;
    int bitmapBytesPerRow = 4 * bounds.size.width;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    CGContextRef context = CGBitmapContextCreate (NULL,
                                                  bounds.size.width,
                                                  bounds.size.height,
                                                  8,
                                                  bitmapBytesPerRow,
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL)
    {
        NSLog(@"getPrintViewForLayerBackedView: Failed to create context.");
        return nil;
    }
    
    [[self layer] renderInContext: context];
    CGImageRef img = CGBitmapContextCreateImage(context);
    /*NSImage* image = [[NSImage alloc] initWithCGImage: img size: bounds.size];
    
    NSImageView* canvas = [[NSImageView alloc] initWithFrame: bounds];
    [canvas setImage: image];
    
    CFRelease(img);
    CFRelease(context);
     */
    
    return img;
}

@end
