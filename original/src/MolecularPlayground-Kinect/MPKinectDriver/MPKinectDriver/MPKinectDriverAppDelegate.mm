//
//  MPKinectDriverAppDelegate.m
//  MPKinectDriver
//
//  Created by Adam on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MPKinectDriverAppDelegate.h"
#import "JSONKit.h"

#define MAGIC_MSG   1
#define TIMEOUT 10

@interface MPKinectDriverAppDelegate ()
- (void)rgbCallback:(uint8_t*)video;
- (void)depthCallback:(uint16_t*)depth;
- (void)startIO;
- (void)stopIO;
- (void)sendDictionary:(NSDictionary *)message;
- (void)sendJSON:(NSString *)json;
@end

static void rgbCallback(freenect_device *dev, void *video, uint32_t timestamp) 
{
	[(MPKinectDriverAppDelegate *)freenect_get_user(dev) rgbCallback:(uint8_t *)video];
}

static void depthCallback(freenect_device *dev, void *depth, uint32_t timestamp) 
{
    [(MPKinectDriverAppDelegate *)freenect_get_user(dev) depthCallback:(uint16_t*)depth];
}

inline static float depthToMeters(short depth) 
{
	return (float)(1.0 / ((double)(depth) * -0.0030711016 + 3.3309495161));
}

inline static double square(double a)
{
	return a * a;
}

inline static void allocateOnDemand( IplImage **img, CvSize size, int depth, int channels )
{
	if ( *img != NULL )	return;
	
	*img = cvCreateImage( size, depth, channels );
	if ( *img == NULL )
	{
		fprintf(stderr, "Error: Couldn't allocate image.  Out of memory?\n");
		exit(-1);
	}
}

void filterForeground(IplImage *im, IplImage *bg, IplImage *mask, float mindiff, float maxdiff) 
{
	
    if(bg == NULL) {
        for(int j = 0; j < 640*480; j++) {
            
            short bVal = 2047;
            short iVal = ((short*)im->imageData)[j];
            if(iVal > 2040) {
                mask->imageData[j] = 0;
                continue;
            }
            short *dest = &((short*)im->imageData)[j];
            float bDepth = depthToMeters(bVal);
            float iDepth = depthToMeters(iVal);
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
    else {
    
        for(int j = 0; j < 640*480; j++) {
            
            short bVal = ((short*)bg->imageData)[j];
            short iVal = ((short*)im->imageData)[j];
            if(iVal > 2040) {
                mask->imageData[j] = 0;
                continue;
            }
            short *dest = &((short*)im->imageData)[j];
            float bDepth = depthToMeters(bVal);
            float iDepth = depthToMeters(iVal);
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
}

@implementation MPKinectDriverAppDelegate

@synthesize window = window_;
@synthesize status = status_;
@synthesize debugging = debugging_;
@synthesize configureWindowController = configureWindowController_;
@synthesize configuring = configuring_;


#pragma mark -
#pragma mark Application Lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"../"]];
    
    NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.2f], @"minMeters", 
                                 [NSNumber numberWithFloat:1.5f], @"maxMeters", 
                                 [NSNumber numberWithInt:160], @"originX",
                                 [NSNumber numberWithInt:120], @"originY",
                                 [NSNumber numberWithInt:320], @"width",
                                 [NSNumber numberWithInt:240], @"height",
                                 [NSNumber numberWithBool:NO], @"upsideDown",
                                 [NSNumber numberWithFloat:2.0f], @"motionScale", nil];
    [myDefaults registerDefaults:appDefaults];
    
    self.status = @"Starting up...";
    
    videoFront_ = (uint8_t *)malloc(FREENECT_VIDEO_RGB_SIZE);
	videoBack_ = (uint8_t *)malloc(FREENECT_VIDEO_RGB_SIZE);
	depthFront_ = (uint16_t *)malloc(FREENECT_DEPTH_11BIT_SIZE);
	depthBack_ = (uint16_t *)malloc(FREENECT_DEPTH_11BIT_SIZE);
    
    socketQueue_ = dispatch_queue_create("SocketQueue", NULL);
    inSocket_ = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue_];
    outSocket_ = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue_];
    state_ = kStateConnected;
    self.debugging = NO;
    self.configuring = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSError *error = nil;
        self.status = @"Connecting to hub...";
        [inSocket_ connectToHost:@"127.0.0.1" onPort:31417 error:&error];
        [outSocket_ connectToHost:@"127.0.0.1" onPort:31417 error:&error];
    });
        
    configureWindowController_ = [[ConfigureWindowController alloc] initWithWindowNibName:@"ConfigureWindow"];    
    [self startIO];
}

- (void)applicationWillTerminate:(NSNotification *)notification 
{
    [self stopIO];
}

- (void)dealloc
{
    dispatch_release(socketQueue_);
    [window_ release];
    [status_ release];
    [inSocket_ release];
    [outSocket_ release];
    [configureWindowController_ release];
    [imageThread_ release];
    [ioThread_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark socket delegate methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port 
{
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"KinectDriver", @"magic", nil];
    
    if(sock == inSocket_) {
        [msg setValue:@"out" forKey:@"role"];
    }
    else {
        [msg setValue:@"in" forKey:@"role"];
    }
    
    NSString *terminatedString = [[NSString alloc] initWithFormat:@"%@\r\n", [msg JSONString]];
    NSData *msgData = [terminatedString dataUsingEncoding:NSUTF8StringEncoding];
    [terminatedString release];
    [sock writeData:msgData withTimeout:TIMEOUT tag:MAGIC_MSG];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag 
{
    NSDictionary *msg = [data objectFromJSONDataWithParseOptions:JKParseOptionPermitTextAfterValidJSON];
    
    if([[msg valueForKey:@"type"] isEqualToString:@"debug"]) {
        self.debugging = [[msg valueForKey:@"status"] isEqualToString:@"on"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.debugging) {
                cvNamedWindow("Debug");
            } 
            else {
                cvDestroyAllWindows();
                NSArray *windows = [[NSApplication sharedApplication] windows];
                for(NSWindow *window in windows) {
                    if([window isKindOfClass:NSClassFromString(@"NSCarbonWindow")])
                        [window close];
                }
            }
        });

    }
    else if([[msg valueForKey:@"type"] isEqualToString:@"configure"]) {
        self.configuring = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.configureWindowController showWindow:self];
            [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps]; 
        });
    }
    else if([[msg valueForKey:@"type"] isEqualToString:@"quit"]) {
        [self stopIO];
        NSLog(@"Kinect should quit");
    }
    [inSocket_ readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag 
{
    if(tag == MAGIC_MSG) {
        if(sock == inSocket_) {
            [inSocket_ readDataWithTimeout:-1 tag:0];
        }
        if([inSocket_ isConnected] && [outSocket_ isConnected]) {
            state_ = kStateConnected;
        }
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err 
{
    state_ = kStateDisconnected;
    [self safeSetStatus:@"Disconnected."];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length 
{
    [sock disconnect];
    return 0.0;
}

#pragma mark -
#pragma mark helper methods

- (void)startIO 
{
    [self setStatus:@"Starting"];
    halt_ = NO;
    [ioThread_ release];
    ioThread_ = [[NSThread alloc] initWithTarget:self selector:@selector(ioThread) object:nil];
    [ioThread_ start];
}

- (void)stopIO 
{
    halt_ = YES;
    while(device_ != NULL) usleep(10000); // crude
}

- (void)safeSetStatus:(NSString *)status {
    
    [self performSelectorOnMainThread:@selector(setStatus:) withObject:status waitUntilDone:NO];
    
}

- (void)showDebugImage
{
    cvShowImage("Debug", debugImage_);
    cvReleaseImage(&debugImage_);
}

- (void)doneConfiguring
{
    self.configuring = NO;
    [imageThread_ release];
    imageThread_ = [[NSThread alloc] initWithTarget:self selector:@selector(imageThread) object:nil];
    [imageThread_ start];
}

- (void)sendJSON:(NSString *)json
{
    NSString *terminatedString = [[NSString alloc] initWithFormat:@"%@\r\n", json];
    NSData *msgData = [terminatedString dataUsingEncoding:NSUTF8StringEncoding];
    [terminatedString release];
    [outSocket_ writeData:msgData withTimeout:TIMEOUT tag:0];
}

- (void)sendDictionary:(NSDictionary *)msg
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self sendJSON:[msg JSONString]];
    [pool release];
}

#pragma mark -
#pragma mark Data capture methods

- (void)rgbCallback:(uint8_t *)buffer 
{
    // update back buffer, then when safe swap with front
    memcpy(videoBack_, buffer, FREENECT_VIDEO_RGB_SIZE);
    @synchronized(self) {
        uint8_t *dest = videoBack_;
        videoBack_ = videoFront_;
        videoFront_ = dest;
        videoUpdate_ = YES;
    }
}

- (void)depthCallback:(uint16_t *)buffer 
{
    // update back buffer, then when safe swap with front
	memcpy(depthBack_, buffer, FREENECT_DEPTH_11BIT_SIZE);		
    @synchronized(self) {
        uint16_t *dest = depthBack_;
        depthBack_ = depthFront_;
        depthFront_ = dest;
        depthUpdate_ = YES;
    }
}

- (uint8_t*)createVideoData 
{
    // safely return front buffer, create a new buffer to take it's place
    uint8_t *src = NULL;
    @synchronized(self) {
        if(videoUpdate_) {
            videoUpdate_ = NO;
            src = videoFront_;
            videoFront_ = (uint8_t*)malloc(FREENECT_VIDEO_RGB_SIZE);
        }
    }
    return src;
}

- (uint16_t*)createDepthData 
{
    // safely return front buffer, create a new buffer to take it's place
    uint16_t *src = NULL;
    @synchronized(self) {
        if(depthUpdate_) {
            depthUpdate_ = NO;
            src = depthFront_;
            depthFront_ = (uint16_t*)malloc(FREENECT_DEPTH_11BIT_SIZE);
        }
    }
    return src;
}

- (IplImage *)cvImage 
{
    static IplImage *image = NULL;
    static uint8_t *data = NULL;
    if(!image) image = cvCreateImageHeader(cvSize(640,480), 8, 3);
    while((data = [self createVideoData]) == NULL) usleep(100);
    cvSetData(image, data, 640*3);
    cvCvtColor(image, image, CV_RGB2BGR);
    IplImage *clone = cvCloneImage(image);
    free(data);
    return clone;
}

- (IplImage *)cvDepth 
{    
    static IplImage *image = NULL;
    static uint16_t *data = NULL;
    if(!image) image = cvCreateImageHeader(cvSize(640,480), 16, 1);
    while((data = [self createDepthData]) == NULL) usleep(100);
    cvSetData(image, data, 640*2);
    IplImage *clone = cvCloneImage(image);
    free(data);
    return clone;
}

#pragma mark -
#pragma mark background model processing

- (IplImage *) backgroundWithSamples:(int)nSamples {
	
	IplImage *bg = NULL;
	bg = [self cvDepth];
	
	for(int i = 0; i < nSamples; i++) {
		IplImage *im = [self cvDepth];
		for(int j = 0; j < 640*480; j++) {
			
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
        cvReleaseImage(&im);
	}
	cvSave("Data/bg.mat", bg);
	return bg;
}


- (void)buildAndSaveBG {
    
    IplImage *bg = [self backgroundWithSamples:100];
    cvReleaseImage(&bg);
}

#pragma mark -
#pragma mark Background threads

- (void)imageThread
{
    [self safeSetStatus:@"Running..."];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    
    NSMutableDictionary *move = [[NSMutableDictionary alloc] initWithCapacity:4];

    NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
    
    float minMeters = [myDefaults floatForKey:@"minMeters"];
    float maxMeters = [myDefaults floatForKey:@"maxMeters"];
    
    int originX = [myDefaults integerForKey:@"originX"];
    int originY = [myDefaults integerForKey:@"originY"];
    int width = [myDefaults integerForKey:@"width"];
    int height = [myDefaults integerForKey:@"height"];
    
    float motionScale = [myDefaults floatForKey:@"motionScale"];
    BOOL upsideDown = [myDefaults boolForKey:@"upsideDown"];
    
    int minX = originX;
    int maxX = originX + width;
    int minY = 480 - (originY + height);
    int maxY = 480 - originY;
    
	CvSize frameSize;
	frameSize.height = 480;
	frameSize.width = 640;
    
    IplImage *bg = (IplImage*)cvLoad("Data/bg.mat");
    IplImage *mask = NULL;
    allocateOnDemand(&mask, cvSize(640,480), IPL_DEPTH_8U, 1);    
    
    while(!halt_ && ![self isConfiguring]) {
        
        IplImage *depth = [self cvDepth];
        filterForeground(depth, bg, mask, minMeters, maxMeters);
        cvErode(mask,mask);	
        cvReleaseImage(&depth);
		
		static IplImage *frame0 = NULL, *frame1 = NULL, 
        *frame0_1C = NULL, *frame1_1C = NULL,
        *eigImage = NULL, *tempImage = NULL, *pyramid0 = NULL,
        *pyramid1 = NULL;
		
		frame0 = [self cvImage];
		
		allocateOnDemand(&frame0_1C, frameSize, IPL_DEPTH_8U, 1);
		cvConvertImage(frame0, frame0_1C, 0);
		
		allocateOnDemand(&frame1, frameSize, IPL_DEPTH_8U, 3);
		cvConvertImage(frame0, frame1, 0);
		
        cvReleaseImage(&frame0);
		frame0 = [self cvImage];
        
		allocateOnDemand(&frame1_1C, frameSize, IPL_DEPTH_8U, 1);
		cvConvertImage(frame0, frame1_1C, 0);
        cvReleaseImage(&frame0);
        
		allocateOnDemand(&eigImage, frameSize, IPL_DEPTH_32F, 1);
		allocateOnDemand(&tempImage, frameSize, IPL_DEPTH_32F, 1);
		
		CvPoint2D32f frame0Features[400];
		
		int numberOfFeatures = 200;
		
		cvGoodFeaturesToTrack(frame0_1C, eigImage, tempImage, frame0Features,
							  &numberOfFeatures, .01, .01, mask);
		
		CvPoint2D32f frame1Features[400];
		char opticalFlowFoundFeature[400];
		float opticalFlowFeatureError[400];
		
		CvSize opticalFlowWindow = cvSize(5,5);
		CvTermCriteria opticalFlowTerminationCriteria 
		= cvTermCriteria(CV_TERMCRIT_ITER | CV_TERMCRIT_EPS, 50, 0.05);
		
		allocateOnDemand(&pyramid0, frameSize, IPL_DEPTH_8U, 1);
		allocateOnDemand(&pyramid1, frameSize, IPL_DEPTH_8U, 1);
		
		cvCalcOpticalFlowPyrLK(frame0_1C, frame1_1C, pyramid0, pyramid1, 
							   frame0Features, frame1Features, numberOfFeatures,
							   opticalFlowWindow, 5, opticalFlowFoundFeature,
							   opticalFlowFeatureError, opticalFlowTerminationCriteria, 0);
		double x_sum = 0.0;
		double y_sum = 0.0;
		int vec_count = 0;
        
		for(int i = 0; i < numberOfFeatures; i++) {
			
			if(opticalFlowFoundFeature[i] == 0) continue;
			
			int lineThickness = 1;
			CvScalar lineColor = CV_RGB(255,0,0);
			
			CvPoint p,q;
			p.x = (int)frame0Features[i].x;
			p.y = (int)frame0Features[i].y;
			q.x = (int)frame1Features[i].x;
			q.y = (int)frame1Features[i].y;
			
			double angle = atan2((double)p.y-q.y, (double)p.x-q.x);
			double hypotenuse = sqrt(square(p.y-q.y) + square(p.x-q.x));
			if(hypotenuse < 2 || hypotenuse > 25) continue;
			if(p.x < minX || p.x > maxX) continue;
			if(p.y < minY || p.y > maxY) continue;
            
			x_sum += (q.x-p.x);
			y_sum += (q.y-p.y);
			vec_count++;
			
			q.x = (int)(p.x - 3 * hypotenuse * cos(angle));
			q.y = (int)(p.y - 3 * hypotenuse * sin(angle));
			
			cvLine(frame1, p, q, lineColor, lineThickness, CV_AA, 0);
		}
        
		if(vec_count > 10) {
            
            double x_mean = x_sum / vec_count;
            double y_mean = y_sum / vec_count;
            
			CvPoint p,q;
			p.x = 320;
			p.y = 240;
			q.x = (float)(320+3*x_mean);
			q.y = (float)(240+3*y_mean);
			cvLine(frame1, p, q, CV_RGB(255,255,255), 1, CV_AA, 0);
            float xMove = (float)(motionScale * (x_sum / vec_count));
            float yMove = (float)(motionScale * (y_sum / vec_count));
            if(upsideDown) {
                yMove = -1 * yMove;
                xMove = -1 * xMove;
            }
            [move setValue:@"move" forKey:@"type"];
            [move setValue:@"rotate" forKey:@"style"];
            [move setValue:[NSNumber numberWithFloat:xMove] forKey:@"x"];
            [move setValue:[NSNumber numberWithFloat:yMove] forKey:@"y"];
            [self sendDictionary:move];
		}
        
        if(frame1 != NULL && [self isDebugging]) {
            debugImage_ = cvCloneImage(frame1);
            [self performSelectorOnMainThread:@selector(showDebugImage) withObject:nil waitUntilDone:YES];
        }
        //cvReleaseImage(&frame);
    }
    [pool drain];
}

- (void)ioThread 
{
    freenect_context *context;
    if(freenect_init(&context, NULL) >= 0) {
        if(freenect_num_devices(context) == 0) {
            [self safeSetStatus:@"No Kinect found"];
        } 
		else if(freenect_open_device(context, &device_, 0) >= 0) {
            freenect_set_user(device_, self);
            freenect_set_depth_callback(device_, depthCallback);
            freenect_set_video_callback(device_, rgbCallback);
            freenect_set_video_format(device_, FREENECT_VIDEO_RGB);
            freenect_set_depth_format(device_, FREENECT_DEPTH_11BIT);
            freenect_start_depth(device_);
            freenect_start_video(device_);
			
            [imageThread_ release];
            imageThread_ = [[NSThread alloc] initWithTarget:self selector:@selector(imageThread) object:nil];
            [imageThread_ start];
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval then = 0;
            while((!halt_ || [imageThread_ isExecuting]) && freenect_process_events(context) >= 0) {
                
                /*
                 freenect_update_device_state(f_dev);
                 freenect_raw_device_state *state = freenect_get_device_state(f_dev);
                 double dx,dy,dz;
                 freenect_get_mks_accel(state, &dx, &dy, &dz);
                 */
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                then = [[NSDate date] timeIntervalSince1970];
                if(then-now > 20) {
                    NSDictionary *pingtionary = [NSDictionary dictionaryWithObject:@"ping" forKey:@"type"];
                    [self sendDictionary:pingtionary];
                    now = then;
                    then = 0;
                }
                usleep(50);
                [pool release];
            }
            
            freenect_close_device(device_);
            device_ = NULL;
            [self safeSetStatus:@"Kinect closed."];
            
        } else {
            [self safeSetStatus:@"Could not open Kinect"];
        }
        freenect_shutdown(context);
    } else {
		[self safeSetStatus:@"Could not init Kinect"];
	}
    [[NSApplication sharedApplication] terminate:self];
}

@end
