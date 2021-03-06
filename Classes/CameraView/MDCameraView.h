//
//  MDCameraView.h
//  MDCameraViewDemo
//
//  Created by mohamed mohamed El Dehairy on 11/2/14.
//  Copyright (c) 2014 mohamed mohamed El Dehairy. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

typedef enum {
    
    cameraTypeFront,
    cameraTypeBack
}cameraType;

@protocol MDCamerViewProtocol <NSObject>

-(void)drawOverLayOnCameraPreviewLayerWithContext:(CGContextRef)context;

@end

@interface MDCameraView : UIView <AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic)BOOL animeModeOn;
@property(nonatomic,weak)id<MDCamerViewProtocol> delegate;

-(void)setRunnging:(BOOL)running;
-(BOOL)isRunning;
-(BOOL)toggleRunning;
-(void)captureStillImageWithCompletion:(void(^)(UIImage *image))completion;
-(void)setcamera:(cameraType)cam;
-(cameraType)currentCamera;
-(cameraType)swictCamera;
@end
