//
//  HYCamera.m
//  FaceDetectedDemo
//
//  Created by MrChen on 2018/4/25.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "HYCamera.h"
#import <AVFoundation/AVFoundation.h>

@interface HYCamera ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, assign) CGRect previewFrame;

// session
@property (nonatomic, strong) AVCaptureSession *captureSession;

// 输入设备
@property (nonatomic, strong) AVCaptureDevice *captureDevice;

// 输入源
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;

// previewlayer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (nonatomic, strong) NSMutableArray *faceIdsArrM;

@property (nonatomic, strong) NSMutableDictionary *faceViewsDicM;

@property (nonatomic, strong) NSMutableDictionary *faceFramesDicM;

@end

@implementation HYCamera

- (instancetype)initWithPreviewFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.previewFrame = frame;
        
        self.faceIdsArrM = [NSMutableArray array];
        self.faceViewsDicM = [NSMutableDictionary dictionary];
        self.faceFramesDicM = [NSMutableDictionary dictionary];
        
        [self initial];
    }
    return self;
}



#pragma mark - 自定义
// 初始化数据
- (void)initial
{
    // 获取摄像头，默认后摄像头
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    // 输入
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice error:nil];

    // 输出
    AVCaptureMetadataOutput *outPut = [AVCaptureMetadataOutput new];
    [outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // session
    self.captureSession = [[AVCaptureSession alloc]init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        [self.captureSession addInput:self.captureDeviceInput];
    }
    
    if ([_captureSession canAddOutput:outPut]) {
        [_captureSession addOutput:outPut];
    }
    outPut.metadataObjectTypes = @[AVMetadataObjectTypeFace];

    //创建预览图层
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_captureSession];
    _captureVideoPreviewLayer.frame = self.previewFrame;
    _captureVideoPreviewLayer.masksToBounds = NO;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    outPut.rectOfInterest = _captureVideoPreviewLayer.bounds;
}

- (void)showInView:(UIView *)view
{
    [view.layer addSublayer:self.captureVideoPreviewLayer];
    
     [_captureSession startRunning];
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.layer.borderWidth = 2;
    view.layer.borderColor = [UIColor redColor].CGColor;
    
    return view;
}


#pragma mark - <#descrip#>
//人脸追踪
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

    NSMutableArray *arrM = [NSMutableArray array];
    for (int i=0; i<metadataObjects.count; i++) {
        AVMetadataObject *metadataObject = metadataObjects[i];
        if ([metadataObject.type isEqual:AVMetadataObjectTypeFace]) {
            AVMetadataFaceObject *face = (AVMetadataFaceObject*)metadataObject;
            NSString *faceId = [NSString stringWithFormat:@"%ld",(long)face.faceID];
            [arrM addObject:faceId];
            
            CGRect faceRectangle = [face bounds];
            CGRect faceRect = [_captureVideoPreviewLayer rectForMetadataOutputRectOfInterest:faceRectangle];
            [self.faceFramesDicM setObject:NSStringFromCGRect(faceRect) forKey:faceId];
            
             CALayer *lay = [self.faceViewsDicM objectForKey:faceId];
            if (lay) {
                lay.frame = faceRect;
            }else {
                CALayer *faceLayer = [[CALayer alloc]init];
                faceLayer.borderColor = [UIColor redColor].CGColor;
                faceLayer.borderWidth = 2;
                faceLayer.frame = faceRect;
                [self.captureVideoPreviewLayer addSublayer:faceLayer];
                [self.faceViewsDicM setObject:faceLayer forKey:faceId];
            }
            

            NSLog(@"+++++%@",faceId);
        }
    }
    
    // 去掉消失的脸
//    for (NSString *str in self.faceIdsArrM) {
//        if (![arrM containsObject:str]) {
//            // 脸消失
//            [self.faceIdsArrM removeObject:str];
//
//            for (NSString *lostFaceId in self.faceViewsDicM) {
//                if ([lostFaceId isEqualToString:str]) {
//                    CALayer *lay = [self.faceViewsDicM objectForKey:lostFaceId];
//                    [lay removeFromSuperlayer];
//                }
//            }
//        }
//    }
    
    // 添加新的脸
//    for (NSString *newFaceStr in arrM) {
//        NSString *newFaceFrame = [self.faceFramesDicM objectForKey:newFaceStr];
//        CGRect newFrame = CGRectFromString(newFaceFrame);
//
//        if (![self.faceIdsArrM containsObject:newFaceStr]) {
//            // 新增的脸
//            [self.faceIdsArrM addObject:newFaceStr];
//
//            CALayer *faceLayer = [[CALayer alloc]init];
//            faceLayer.borderColor = [UIColor redColor].CGColor;
//            faceLayer.borderWidth = 2;
//            faceLayer.frame = newFrame;
//            [self.captureVideoPreviewLayer addSublayer:faceLayer];
//        }else {
//            // 跟踪脸的位置
//            CALayer *lay = [self.faceViewsDicM objectForKey:newFaceStr];
//            lay.frame = newFrame;
//        }
//    }
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{

}


@end
