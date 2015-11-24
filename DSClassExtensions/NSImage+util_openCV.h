//
//  NSImage+util_openCV
//

#include <opencv2/opencv.hpp>
#import <AppKit/AppKit.h>
@interface NSImage (NSImage_util_openCV) {}

+(NSImage*)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;
+(IplImage *)iplImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer ;
@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

@end