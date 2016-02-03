#import "MotionSource.h"

@interface MotionSource (Private)
- (NSWindowController *)debugWindowController;
- (NSWindowController *)configureWindowController;
- (IplImage *)subImageOfImage:(IplImage *)image withROI:(CvRect)roi;
- (void)motionThread;
- (void)rgbCallback:(IplImage *)image;
- (uint8_t *)rgbImage;
@end