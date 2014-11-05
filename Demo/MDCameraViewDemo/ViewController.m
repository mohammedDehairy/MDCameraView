//
//  ViewController.m
//  MDCameraViewDemo
//
//  Created by mohamed mohamed El Dehairy on 11/2/14.
//  Copyright (c) 2014 mohamed mohamed El Dehairy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    IBOutlet MDCameraView *camView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [camView setRunnging:YES];
    [camView setAnimeModeOn:YES];
    camView.delegate = self;
}

-(IBAction)capture:(id)sender
{
    [camView captureStillImageWithCompletion:^(UIImage* image){
        
        
        
    }];
}
-(IBAction)switchCamera:(id)sender
{
    [camView swictCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)drawOverLayOnCameraPreviewLayerWithContext:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextAddRect(context, CGRectMake(50, 50, 100, 100));
    CGContextStrokePath(context);
}

@end
