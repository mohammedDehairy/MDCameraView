//
//  MDCameraView.m
//  MDCameraViewDemo
//
//  Created by mohamed mohamed El Dehairy on 11/2/14.
//  Copyright (c) 2014 mohamed mohamed El Dehairy. All rights reserved.
//

#import "MDCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>

@interface MDCameraView ()
{
    AVCaptureSession *session;
    AVCaptureDevice *backDevice;
    AVCaptureDeviceInput *backDeviceInput;
    AVCaptureDevice *frontDevice;
    AVCaptureDeviceInput *frontDeviceInput;
    //AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureVideoDataOutput *dataOutput;
    AVCaptureStillImageOutput *stillImageOuPut;
    
    UIImage *lastImage;
    
    UIImageView *preImageLayer;
    
    cameraType currentCamType;
    
    CALayer *previewLayer;
}
@end

@implementation MDCameraView

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self initalizeVideoSession];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        
        
        [self initalizeVideoSession];
        
    }
    
    return self;
}
-(void)initalizeVideoSession
{
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    backDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            frontDevice = device;
        }
    }
    NSError *err;
    frontDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontDevice error:&err];
    
    
    
    backDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backDevice error:&err];
    
    if(!backDeviceInput)
    {
        NSLog(@"%@",err.localizedDescription);
    }
    
    [session addInput:backDeviceInput];
    
    //self.layer.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    /*previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    previewLayer.frame = CGRectMake(0, 0, self.layer.bounds.size.width, self.layer.bounds.size.height);
    //[self orientationChanged];
    [self.layer addSublayer:previewLayer];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;*/
    previewLayer = [CALayer layer];
    previewLayer.frame = CGRectMake(0, 0, self.layer.bounds.size.width, self.layer.bounds.size.height);
    [self.layer addSublayer:previewLayer];
    previewLayer.contentsGravity = kCAGravityResizeAspectFill;
    
    
    dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:
                              [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                         forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    dispatch_queue_t queue = dispatch_queue_create("dataOutputQueue", DISPATCH_QUEUE_SERIAL);
    
    [dataOutput setSampleBufferDelegate:self queue:queue];
    
    if([session canAddOutput:dataOutput])
    {
        [session addOutput:dataOutput];
    }
    
    [[dataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    [[dataOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    
    stillImageOuPut = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outPutSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [stillImageOuPut setOutputSettings:outPutSettings];
    [session addOutput:stillImageOuPut];
    
    currentCamType = cameraTypeBack;
}
-(AVCaptureVideoOrientation)videoOrientationforCurrent
{
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
    }
}

-(void)setRunnging:(BOOL)running
{
    if(running)
    {
        [session startRunning];
    }else
    {
        [session stopRunning];
        
    }
}
-(BOOL)isRunning
{
    return [session isRunning];
}
-(BOOL)toggleRunning
{
    if([self isRunning])
    {
        [self setRunnging:NO];
        return NO;
    }else
    {
        [self setRunnging:YES];
        return YES;
    }
}
-(void)setAnimeModeOn:(BOOL)animeModeOn
{
    if(animeModeOn)
    {
        
        
        [self populateAnimeLayerWithLastImage];
        
        
    }
}

-(void)populateAnimeLayerWithLastImage
{
    
    if(!preImageLayer)
    {
        preImageLayer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self addSubview:preImageLayer];
        preImageLayer.contentMode = UIViewContentModeScaleAspectFill;
        
    }
    
    if(lastImage)
    {
        [preImageLayer setImage:lastImage];
        [preImageLayer setAlpha:0.5];
    }
}
-(void)captureStillImageWithCompletion:(void(^)(UIImage *image))completion
{
    
    
    AVCaptureConnection *videoConnection = [stillImageOuPut connectionWithMediaType:AVMediaTypeVideo];
    if([videoConnection isVideoOrientationSupported])
    {
        [videoConnection setVideoOrientation:[self videoOrientationforCurrent]];
    }
    
    
    [stillImageOuPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             NSLog(@"attachements: %@", exifAttachments);
         } else {
             NSLog(@"no attachments");
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         dispatch_async(dispatch_get_main_queue(), ^(void){
             
             completion(image);
             
         });
         
         
         lastImage = image;
         
         [self  populateAnimeLayerWithLastImage];
         
         
     }];
}
-(AVCaptureDeviceInput*)captureDeviceInputWithType:(cameraType)type
{
    switch (type) {
        case cameraTypeBack:
            return backDeviceInput;
            break;
            
        default:
            return frontDeviceInput;
            break;
    }
}
-(void)setcamera:(cameraType)cam
{
    if(cam == currentCamType)
    {
        return;
    }
    
    [session beginConfiguration];
    
    // Remove the current video input device.
    [session removeInput:[self captureDeviceInputWithType:currentCamType]];
    
    if ([session canAddInput:[self captureDeviceInputWithType:cam]]) {
        [session addInput:[self captureDeviceInputWithType:cam]];
    }
    
    else {
        [session addInput:[self captureDeviceInputWithType:currentCamType]];
    }
    
    currentCamType = cam;
    
    [session commitConfiguration];
    
    [[dataOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[self videoOrientationforCurrent]];
}
-(cameraType)currentCamera
{
    return currentCamType;
}
-(cameraType)swictCamera
{
    if(currentCamType == cameraTypeBack)
    {
        [self setcamera:cameraTypeFront];
        return cameraTypeFront;
    }else
    {
        [self setcamera:cameraTypeBack];
        return cameraTypeBack;
    }
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    if(!_delegate || ![_delegate respondsToSelector:@selector(drawOverLayOnCameraPreviewLayerWithContext:)])
    {
        return;
    }
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    
    dispatch_sync(dispatch_get_main_queue(), ^(void){
    
    
        // Create a device-dependent RGB color space
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create a bitmap graphics context with the sample buffer data
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                     bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        
        
        
        
        if (!context)
        {
            CGColorSpaceRelease(colorSpace);
            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
            NSLog(@"Error creating bitmap context");
            return ;
        }
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
        transform = CGAffineTransformTranslate(transform, 0.0f, -height);
        CGContextConcatCTM(context, transform);
        
        
        // Perform drawing
        UIGraphicsPushContext(context);
        [_delegate drawOverLayOnCameraPreviewLayerWithContext:context];
        UIGraphicsPopContext();
        
        CGImageRef cgimage = CGBitmapContextCreateImage(context);
        [previewLayer setContents:(__bridge id)cgimage];
        CGImageRelease(cgimage);
        
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        
    
    });
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
