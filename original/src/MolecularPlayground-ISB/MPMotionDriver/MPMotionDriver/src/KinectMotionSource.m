//
//  KinectMotionSource.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KinectMotionSource.h"

//
// C function prototypes
//
void filterForeground(IplImage *im, IplImage *bg, IplImage *mask, float mindiff, float maxdiff);

@interface KinectMotionSource ()
- (IplImage *)cvColorImage;
- (IplImage *)cvDepth;
- (IplImage *)backgroundWithSamples:(int)nSamples;
- (void)refreshParameters;
@end

@implementation KinectMotionSource
{
    float _minX;
    float _minY;
    float _maxX;
    float _maxY;
    float _minMeters;
    float _maxMeters;
    float _motionScale;
    BOOL _upsideDown; 
}

- (id)init
{
    self = [super init];
    if(self) {
        [self refreshParameters];
    }
    return self;
}

- (void)dealloc
{    
    [super dealloc];
}

- (void)refreshParameters
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _minX = [defaults floatForKey:MPMinXKey];
    _minY = [defaults floatForKey:MPMinYKey];
    _maxX = [defaults floatForKey:MPMaxXKey];
    _maxY = [defaults floatForKey:MPMaxYKey];
    _minMeters = [defaults floatForKey:MPMinMetersKey];
    _maxMeters = [defaults floatForKey:MPMaxMetersKey];
    _motionScale = [defaults floatForKey:MPMotionScaleKey];
    _upsideDown = [defaults boolForKey:MPUpsideDownKey];    
}

- (NSWindowController *)configureWindowController
{
    if(_configureWindowController == nil) {
        _configureWindowController = [[KinectConfigureWindowController alloc] init];
    }
    _configureWindowController.imageSource = self;
    _configureWindowController.window.delegate = self;
    _configureWindowController.configDelegate = self;
    [_configureWindowController refreshSettings];
    return _configureWindowController;
}

- (void)configControllerWillSave:(ConfigureWindowController *)controller
{
    [self refreshParameters];
    IplImage *bgModel = [self backgroundWithSamples:100];
    NSString *bgPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:MPBackgroundModelFile];
    cvSave([bgPath UTF8String], bgModel, NULL, NULL, cvAttrList(NULL, NULL));
    cvReleaseImage(&bgModel);
}

/*
 * cvColorImage returns an IplImage version of the RGB Kinect image
 * The returned IplImage should NOT be released by the receiver.
 */
- (IplImage *)cvColorImage
{
    static IplImage *image = NULL;
    if(image == NULL) {
        image = cvCreateImageHeader(_frameSize, IPL_DEPTH_8U, 3);
    }
    uint8_t *data = [KinectDevice colorImage];
    cvSetData(image, data, _frameSize.width * 3);
    return image;
}

/*
 * cvDepth returns an IplImage version of the Kinect depth map
 * The returned IplImage should NOT be released by the receiver.
 */
- (IplImage *)cvDepth
{
    static IplImage *depth = NULL;
    if(depth == NULL) {
        depth = cvCreateImage(_frameSize, 16, 1);
    }
    uint16_t *data = [KinectDevice depthImage];
    cvSetData(depth, data, _frameSize.width * 2);
    return depth;
}

///*
// * rgbImage returns a copy of the raw Kinect RGB image
// * The receiver should free() the returned pointer
// */
//- (uint8_t *)rgbImage
//{
//    uint8_t *imageCopy = malloc(MPFrameRGBSize);
//    uint8_t *image = [KinectDevice colorImage];
//    memcpy(imageCopy, image, MPFrameRGBSize);
//    return imageCopy;    
//}

/*
 * depthImage returns a copy of the raw Kinect depth map
 * The receiver should free() the returned pointer
 */
- (uint16_t *)depthImage
{
    size_t depthSize = MPFrameWidth * MPFrameHeight * sizeof(uint16_t);
    uint16_t *depthCopy = malloc(depthSize);
    uint16_t *depth = [KinectDevice depthImage];
    memcpy(depthCopy, depth, depthSize);
    return depthCopy;
}

void filterForeground(IplImage *im, IplImage *bg, IplImage *mask, float mindiff, float maxdiff) 
{
    for(int j = 0; j < MPFrameWidth*MPFrameHeight; j++) {
        
        short bVal = ((short*)bg->imageData)[j];
        short iVal = ((short*)im->imageData)[j];
        if(iVal > 2040) {
            mask->imageData[j] = 0;
            continue;
        }
        short *dest = &((short*)im->imageData)[j];
        float bDepth = (float)(1.0 / ((double)(bVal) * -0.0030711016 + 3.3309495161));
        float iDepth = (float)(1.0 / ((double)(iVal) * -0.0030711016 + 3.3309495161));
        float diff = bDepth - iDepth;
        if(bVal > 2040 || (diff >= mindiff && diff <= maxdiff)) {
            *dest = iVal;
            mask->imageData[j] = 250;
        }
        else {
            *dest = 2047;
            mask->imageData[j] = 0;
        }
    }
}

- (IplImage *) backgroundWithSamples:(int)nSamples {
	
	IplImage *bg = cvCloneImage([self cvDepth]);
	
	for(int i = 0; i < nSamples; i++) {
		IplImage *im = [self cvDepth];
		for(int j = 0; j < MPFrameWidth*MPFrameHeight; j++) {
			
			short bVal = ((short*)bg->imageData)[j];
			short iVal = ((short*)im->imageData)[j];
			if(iVal > 2040) continue;
			short *dest = &((short*)bg->imageData)[j];
			if(bVal > 2040)
				*dest = iVal;
			else {
				short avg = (short)(0.7*bVal+0.3*iVal);
				*dest = avg;
			}
		}
	}
	return bg;
}

- (void)motionThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
    IplImage *frame = NULL, *rgbFrame = NULL, 
    *frame0Mono = NULL, *frame1Mono = NULL, 
    *eigImage = NULL, *tempImage = NULL, 
    *pyramid0 = NULL, *pyramid1 = NULL, 
    *mask = NULL;
    
    rgbFrame = cvCreateImage(_frameSize, IPL_DEPTH_8U, 3);
    frame0Mono = cvCreateImage(_frameSize, IPL_DEPTH_8U, 1);
    frame1Mono = cvCreateImage(_frameSize, IPL_DEPTH_8U, 1);
    eigImage = cvCreateImage(_frameSize, IPL_DEPTH_32F, 1);
    tempImage = cvCreateImage(_frameSize, IPL_DEPTH_32F, 1);
    pyramid0 = cvCreateImage(_frameSize, IPL_DEPTH_32F, 1);
    pyramid1 = cvCreateImage(_frameSize, IPL_DEPTH_32F, 1);
    mask = cvCreateImage(_frameSize, IPL_DEPTH_8U, 1);
    
    IplImage *bgModel = (IplImage *)cvLoad([MPBackgroundModelFile UTF8String], NULL, NULL, NULL);
    
    while(!_halt) {
        
        if(self.configuring) {
            frame = [self cvColorImage];
            cvConvertImage(frame, rgbFrame, 0);
            [self rgbCallback:rgbFrame];
            continue;
        }
        
        IplImage *depth = [self cvDepth];
        IplImage *actualMask = NULL;
        if(bgModel != NULL) {
            filterForeground(depth, bgModel, mask, _minMeters, _maxMeters);
            actualMask = mask;
        }
        
        frame = [self cvColorImage];
        cvConvertImage(frame, frame0Mono, 0);
        cvConvertImage(frame, rgbFrame, 0);
        
        frame = [self cvColorImage];
        cvConvertImage(frame, frame1Mono, 0);
        
        CvPoint2D32f frame0Features[200];
        int numberOfFeatures = 200;
        
        cvGoodFeaturesToTrack(frame0Mono, eigImage, tempImage, 
                              frame0Features, &numberOfFeatures, 
                              0.01, 0.01, actualMask, 5, 0, 0.04);
        
        CvPoint2D32f frame1Features[200];
        char opticalFlowFoundFeature[200];
        float opticalFlowFeatureError[200];
        
        CvSize opticalFlowWindow = cvSize(5, 5);
        CvTermCriteria opticalFlowTerminationCriteria = cvTermCriteria(CV_TERMCRIT_ITER | CV_TERMCRIT_EPS,
                                                                       50, 0.05);
        cvCalcOpticalFlowPyrLK(frame0Mono, frame1Mono, pyramid0, pyramid1, 
                               frame0Features, frame1Features, numberOfFeatures, 
                               opticalFlowWindow, 5, opticalFlowFoundFeature, 
                               opticalFlowFeatureError, opticalFlowTerminationCriteria, 0);
        
        double xSum = 0.0;
        double ySum = 0.0;
        int vectorCount = 0;
        
        for(int i = 0; i < numberOfFeatures; i++) {
            
            if(opticalFlowFoundFeature[i] == 0) continue;
            
            CvPoint p, q;
            p.x = (int)frame0Features[i].x;
            p.y = (int)frame0Features[i].y;
            q.x = (int)frame1Features[i].x;
            q.y = (int)frame1Features[i].y;
            
            double hypotenuseSquared = (p.y-q.y)*(p.y-q.y) + (p.x-q.x)*(p.x-q.x);
            if(hypotenuseSquared < 4 || hypotenuseSquared > 625) continue;
            if(p.x < _minX || p.x > _maxX) continue;
            if(p.y < _minY || p.y > _maxY) continue;
            
            xSum += (q.x-p.x);
            ySum += (q.y-p.y);
            vectorCount++;
            
            if([self isDebugging]) {
                
                int lineThickness = 1;
                CvScalar lineColor = CV_RGB(255, 0, 0);
                double angle = atan2((double)p.y - q.y, (double)p.x - q.x);
                double hypotenuse = sqrt(hypotenuseSquared);
                
                q.x = (int)(p.x - 3 * hypotenuse * cos(angle));
                q.y = (int)(p.y - 3 * hypotenuse * sin(angle));
                
                cvLine(rgbFrame, p, q, lineColor, lineThickness, CV_AA, 0);
            }
        }
        
        if(vectorCount > 10) {
            double xMean = xSum / vectorCount;
            double yMean = ySum / vectorCount;
            float xMove = (float)(_motionScale * xMean);
            float yMove = (float)(_motionScale * yMean);
            if(_upsideDown) {
                xMove = -1 * xMove;
                yMove = -1 * yMove;
            }
            [self.delegate motionSource:self didRotateByX:xMove andY:yMove];
            
            if([self isDebugging]) {
                CvPoint p, q;
                p.x = MPFrameWidth / 2;
                p.y = MPFrameHeight / 2;
                q.x = (float)(p.x + 3 * xMean);
                q.y = (float)(p.y + 3 * yMean);
                cvLine(rgbFrame, p, q, CV_RGB(0, 0, 255), 1, CV_AA, 0);
            }
        }
        
        if([self isDebugging]) {
            [self rgbCallback:rgbFrame];
        }
    }
    
    cvReleaseImage(&rgbFrame);
    cvReleaseImage(&frame0Mono);
    cvReleaseImage(&frame1Mono);
    cvReleaseImage(&eigImage);
    cvReleaseImage(&tempImage);
    cvReleaseImage(&pyramid0);
    cvReleaseImage(&pyramid1);
    
    [pool drain];
}

@end
