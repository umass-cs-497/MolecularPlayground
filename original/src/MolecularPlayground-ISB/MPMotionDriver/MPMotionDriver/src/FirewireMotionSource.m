//
//  FirewireMotionSource.m
//  MPMotionDriver
//
//  Created by Adam Williams on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirewireMotionSource.h"

@interface FirewireMotionSource ()
- (void)refreshParameters;
@end

@implementation FirewireMotionSource
{
    FirewireContext *_context;
    FirewireCamera *_camera;
    
    float _minX;
    float _minY;
    float _maxX;
    float _maxY;
    float _motionScale;
    BOOL _upsideDown;
}

- (id)init
{
    self = [super init];
    if(self) {
        _context = [[FirewireContext alloc] init];
        _camera = [[_context camera] retain];        
        [_camera start];
        [self refreshParameters];
    }
    return self;
}

- (void)dealloc
{
    [_camera stop];
    [_camera release];
    [_context release];
    
    [super dealloc];
}

- (void)refreshParameters
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _minX = [defaults floatForKey:MPMinXKey];
    _minY = [defaults floatForKey:MPMinYKey];
    _maxX = [defaults floatForKey:MPMaxXKey];
    _maxY = [defaults floatForKey:MPMaxYKey];
    _motionScale = [defaults floatForKey:MPMotionScaleKey];
    _upsideDown = [defaults boolForKey:MPUpsideDownKey];
    [_camera setShutterSpeed:[defaults integerForKey:MPShutterSpeedKey]];
}

- (NSWindowController *)configureWindowController
{
    if(_configureWindowController == nil) {
        _configureWindowController = [[FirewireConfigureWindowController alloc] initWithCamera:_camera];
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
}

- (void)motionThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    IplImage *frame = NULL, *rgbFrame = NULL, 
             *frame0Mono = NULL, *frame1Mono = NULL, 
             *eigImage = NULL, *tempImage = NULL, 
             *pyramid0 = NULL, *pyramid1 = NULL;
        
    frame = cvCreateImage(_frameSize, IPL_DEPTH_8U, 1);
    rgbFrame = cvCreateImage(_frameSize, IPL_DEPTH_8U, 3);
    frame0Mono = cvCreateImage(_frameSize, IPL_DEPTH_8U, 1);
    frame1Mono = cvCreateImage(_frameSize, IPL_DEPTH_8U, 1);
    eigImage = cvCreateImage(_frameSize, IPL_DEPTH_32F, 1);
    tempImage = cvCreateImage(_frameSize, IPL_DEPTH_32F, 1);
    pyramid0 = cvCreateImage(_frameSize, IPL_DEPTH_32F, 1);
    pyramid1 = cvCreateImage(_frameSize, IPL_DEPTH_32F, 1);
    
    while(!_halt) {
        
        if(self.configuring) {
            [_camera imageForCVImage:frame];
            cvConvertImage(frame, rgbFrame, 0);
            [self rgbCallback:rgbFrame];
            continue;
        }
        
        if([_camera imageForCVImage:frame] == NULL) break;
        cvConvertImage(frame, frame0Mono, 0);
        cvConvertImage(frame, rgbFrame, 0);
        
        if([_camera imageForCVImage:frame] == NULL) break;
        cvConvertImage(frame, frame1Mono, 0);
        
        CvPoint2D32f frame0Features[200];
        int numberOfFeatures = 200;
        
        cvGoodFeaturesToTrack(frame0Mono, eigImage, tempImage, 
                              frame0Features, &numberOfFeatures, 
                              0.1, 0.01, NULL, 5, 0, 0.04);
        
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
    
    cvReleaseImage(&frame);
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
