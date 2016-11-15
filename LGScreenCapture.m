//
//  LGScreenShack.m
//  text1
//
//  Created by 东途 on 2016/11/1.
//  Copyright © 2016年 displayten. All rights reserved.
//

#import "LGScreenCapture.h"

@interface LGScreenCapture()
<AVCaptureVideoDataOutputSampleBufferDelegate,
 AVCaptureAudioDataOutputSampleBufferDelegate>
@property (strong, nonatomic)   AVCaptureScreenInput *input;
@property (strong, nonatomic)   AVCaptureSession *session;
@property (strong, nonatomic)   AVCaptureVideoDataOutput *videoOutput;
@property (strong, nonatomic)   AVCaptureAudioDataOutput *audioOutput;
@property ( copy,  nonatomic)   void(^callBack)(CMSampleBufferRef sampleBuffer, LGScreenCaptureType type);
@end
@implementation LGScreenCapture {
    CGRect _rect;
    CGSize _screenSize;
    BOOL _isRunning;
}


#pragma mark Interface
+ (instancetype)lg_videoScreenCaptureWithCallbackQueueVideoQueue:(dispatch_queue_t)videoQueue audioQueue:(dispatch_queue_t)audioQueue callBack:(void(^)(CMSampleBufferRef sampleBuffer, LGScreenCaptureType type))callBack {
    return [[self alloc] initWithCallBackQueueVideoQueue:videoQueue audioQueue:audioQueue callBack:callBack];
}

- (void)start {
    
    if (!_isRunning) {
        [self.session startRunning];
        _isRunning = YES;
    }
}
- (void)stop {
    if (_isRunning) {
        [self.session stopRunning];
        _isRunning = NO;
    }
}
- (void)exit {
    if (_isRunning) {
        [self.session stopRunning];
        _isRunning = NO;
    }
    self.session = nil;
    self.input = nil;
    self.videoOutput = nil;
    self.audioOutput = nil;
}
- (CGRect)screenRect {
    return _rect;
}
- (CGSize)screenSize {
    return _rect.size;
}
- (BOOL)isStart {
    return _isRunning;
}

#pragma mark Tools
- (instancetype)initWithCallBackQueueVideoQueue:(dispatch_queue_t)videoQueue audioQueue:(dispatch_queue_t)audioQueue callBack:(void(^)(CMSampleBufferRef sampleBuffer, LGScreenCaptureType type))callBack {
    if (self = [super init]) {
        self.callBack = callBack;
        _rect = [LGScreenCapture screenRect];
        if (![self addCaptureWithVideoQueue:videoQueue audioQueue:audioQueue]) {
            return nil;
        }
    }
    return self;
}
- (BOOL)addCaptureWithVideoQueue:(dispatch_queue_t)videoQueue audioQueue:(dispatch_queue_t)audioQueue {
    
    int maxFrameRate;
    if (self.maxFrameRate) {
        maxFrameRate = self.maxFrameRate;
    }
    else maxFrameRate = 30;
    
// session
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    else return NO;
    
// input
    CGDirectDisplayID displayID = CGMainDisplayID();
    self.input = [[AVCaptureScreenInput alloc] initWithDisplayID:displayID];
    if (!self.input) return NO;
    self.input.capturesCursor = YES;
    self.input.capturesMouseClicks = YES;            // 捕捉鼠标
    self.input.minFrameDuration = CMTimeMake(1, maxFrameRate); // 帧率
    //input.scaleFactor = 0.5f;                   // 缩放比例
    self.input.cropRect = _rect;                   // 最后输出的裁剪区域
    if ([self.session canAddInput:self.input]) [self.session addInput:self.input];
    else return NO;
    
// output
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.videoSettings =
    [NSDictionary dictionaryWithObjectsAndKeys:@(kCVPixelFormatType_32BGRA),kCVPixelBufferPixelFormatTypeKey, [NSNumber numberWithInt:_rect.size.width], kCVPixelBufferWidthKey, [NSNumber numberWithInt:_rect.size.height], kCVPixelBufferHeightKey, nil];
    self.videoOutput.alwaysDiscardsLateVideoFrames = true;
    [self.videoOutput setSampleBufferDelegate:self queue:videoQueue];
    if ([self.session canAddOutput:self.videoOutput]) [self.session addOutput:self.videoOutput];
    else return NO;
    
    
    
// audio
//    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
//    [_audioOutput setSampleBufferDelegate:self queue:audioQueue];
//    _audioOutput.audioSettings = @{};
//    if ([self.session canAddOutput:_audioOutput]) [self.session addOutput:_audioOutput];
//    else return NO;
    
// conncetion
    //    AVCaptureConnection *connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    //    [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    //    if ([connection isVideoMirroringSupported]) {
    //        connection.videoMirrored = YES;
    //    }
    return YES;
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @synchronized (self) {
        if (self.videoOutput == captureOutput) {
            self.callBack(sampleBuffer, LGScreenCaptureTypeVideo);
        }
        else if (self.audioOutput == captureOutput) {
            self.callBack(sampleBuffer, LGScreenCaptureTypeAudio);
        }
    }
}
+ (NSRect)screenRect {
    NSRect screenRect;
    NSArray *screenArray = [NSScreen screens];
    NSScreen *screen = [screenArray objectAtIndex: 0];
    screenRect = [screen frame];//[screen visibleFrame];
    return screenRect;
}

#pragma mark Text here
-(void)addCaptureVideoPreview {
    /* Create a video preview layer. */
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    NSView *view = [[NSView alloc]initWithFrame:CGRectMake(0, 0, _screenSize.width*0.7, _screenSize.height*0.7)];
//    [self.view addSubview:view];
    
    /* Configure it.*/
    [videoPreviewLayer setFrame:[[view layer] bounds]];
    [videoPreviewLayer setAutoresizingMask:kCALayerWidthSizable|kCALayerHeightSizable];
    
    /* Add the preview layer as a sublayer to the view. */
    [[view layer] addSublayer:videoPreviewLayer];
    /* Specify the background color of the layer. */
    [[view layer] setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
}
@end
