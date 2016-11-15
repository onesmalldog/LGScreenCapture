
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>

typedef enum : NSUInteger {
    LGScreenCaptureTypeVideo,
    LGScreenCaptureTypeAudio
} LGScreenCaptureType;

@interface LGScreenCapture : NSObject
@property (assign, readonly, nonatomic) CGRect screenRect;
@property (assign, readonly, nonatomic) CGSize screenSize;
@property (assign, readonly, nonatomic) BOOL isStart;
@property (assign, nonatomic) int maxFrameRate;
+ (instancetype)lg_videoScreenCaptureWithCallbackQueueVideoQueue:(dispatch_queue_t)videoQueue audioQueue:(dispatch_queue_t)audioQueue callBack:(void(^)(CMSampleBufferRef sampleBuffer, LGScreenCaptureType type))callBack;
- (void)start;
- (void)stop;
- (void)exit;
@end
