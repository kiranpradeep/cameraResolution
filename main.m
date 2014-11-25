
#import "AVFoundation/AVFoundation.h"

@interface Camera : NSObject
- (id) init ;
- (void) start;
@end


@interface Camera ()

@property AVCaptureSession* session;
@end

@implementation Camera

- (id) init
{
    
    self = [super init];
    _session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    double width = 800.0;
    double height = 600.0;
    
    AVCaptureVideoDataOutput* output = [[AVCaptureVideoDataOutput alloc] init];
    [[output connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    NSDictionary *pixelBufferOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithDouble:width], (id)kCVPixelBufferWidthKey,
                                        [NSNumber numberWithDouble:height], (id)kCVPixelBufferHeightKey,
                                        [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
                                        nil];
    [output setVideoSettings:pixelBufferOptions];
    
    
    [_session beginConfiguration ];
    [_session addInput:input];
    [_session addOutput:output];
    [_session setSessionPreset:AVCaptureSessionPreset640x480];
    [ _session commitConfiguration ];
    
    dispatch_queue_t queue = dispatch_queue_create("camera.queue", DISPATCH_QUEUE_SERIAL);
    [output setSampleBufferDelegate:self queue:queue];
    
    return self;
}

- (void) start
{
    [self.session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    NSLog(@"Size - %zd : %zd", width, height);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}


@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Camera* videoCamera = [[Camera alloc] init];
        [videoCamera start];
        [NSThread sleepForTimeInterval:10.0f];
    }
    return 0;
}
